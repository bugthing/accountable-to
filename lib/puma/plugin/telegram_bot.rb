require "puma/plugin"

Puma::Plugin.create do
  attr_reader :puma_pid, :bot_process_pid, :log_writer

  def start(launcher)
    @log_writer = launcher.log_writer
    @puma_pid = $$

    in_background do
      monitor_bot_process
    end

    launcher.events.on_booted do
      @bot_process_pid = fork do
        Thread.new { monitor_puma }
        load Rails.root.join("bin", "telegram_bot_client")
      end
    end

    launcher.events.on_stopped { stop_bot_process }
    launcher.events.on_restart { stop_bot_process }
  end

  def stop_bot_process
    Process.waitpid(bot_process_pid, Process::WNOHANG)
    log "Puma plugin stopping telegram bot..."
    Process.kill(:INT, bot_process_pid) if bot_process_pid
    Process.wait(bot_process_pid)
  rescue Errno::ECHILD, Errno::ESRCH
  end

  def monitor_puma
    monitor(:puma_dead?, "Detected Puma has gone away, stopping bot...")
  end

  def monitor_bot_process
    monitor(:bot_process_dead?, "Detected bot has gone away, stopping Puma...")
  end

  def monitor(check_method, message)
    loop do
      if send(check_method)
        log message
        Process.kill(:INT, $$)
        break
      end
      sleep 2
    end
  end

  def bot_process_dead?
    if bot_process_started?
      Process.waitpid(bot_process_pid, Process::WNOHANG)
    end
    false
  rescue Errno::ECHILD, Errno::ESRCH
    true
  end

  def bot_process_started? = bot_process_pid.present?

  def puma_dead? = Process.ppid != puma_pid

  def log(...) = log_writer.log(...)
end
