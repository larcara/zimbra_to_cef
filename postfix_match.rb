module PostfixMatch




  TIME_AND_PID= /(?<time>[\w]+\s+[\d]+\s[\d:]+)\s+(?<host>[\w]+)\s+(?<process>[\w\/]+)\[(?<pid>[\d]+)\]\:/
  TO= /#{TIME_AND_PID}\s(?<queue_id>[\w]{11,14}):\sto=(?<to_address>[^,]+),\s(orig_to=(?<orig_to_address>[^,]+),)?\srelay=(?<relay>[^,]+),\sdelay=(?<delay>[^,]+),\sdelays=(?<delays>[^,]+),\sdsn=(?<dns>[^,]+),\sstatus=(?<status>[\w]+)\s\((?<message>(.*))\)/
  FROM= /#{TIME_AND_PID}\s(?<queue_id>[\w]{11,14}):\sfrom=(?<from_address>[^,]+),\ssize=(?<size>[^,]+),\snrcpt=(?<nrcpt>[\w]+)\s\((?<message>(.*))\)/
  OTHER= /#{TIME_AND_PID}\s(?<queue_id>[\w]{11,14}):\s(?<data>.+)/


  REG_EXPS = [TO,FROM,OTHER]
  TO_SKIP = []
end