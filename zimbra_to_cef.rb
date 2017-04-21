require 'rubygems'
require 'cef'

cef_sender=CEF::UDPSender.new
cef_sender.receiver="10.211.55.15"
cef_sender.receiverPort=514



filename = "dummy.file"

File.open(filename) do |log|
  log.extend(File::Tail)
  log.interval # 10
  log.backward(10)
  log.tail do |line|
    if line.match("postfix/(.*)\[(.*)]: ([0-9A-Z]{12,14})")
      cef_event=CEF::Event.new
      cef_event.attrs[:deviceCustomString1] = line
      cef_sender.emit(cef_event)
    end
  end
end
