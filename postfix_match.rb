module PostfixMatch
  TIME_AND_PID= /(?<startTime>[\w]+\s+[\d]+\s[\d:]+)\s+(?<agentHostName>[\w]+)\s+(?<deviceAction>[\w\/]+)\[(?<eventId>[\d]+)\]\:/
  TO= /#{TIME_AND_PID}\s(?<queue_id>[\w]{11,14}):\sto=(?<destinationAddress>[^,]+),\s(orig_to=(?<destinationUserName>[^,]+),)?\srelay=(?<relay>[^,]+),\sdelay=(?<delay>[^,]+),\sdelays=(?<delays>[^,]+),\sdsn=(?<dns>[^,]+),\sstatus=(?<status>[\w]+)\s\((?<message>(.*))\)/
  FROM= /#{TIME_AND_PID}\s(?<queue_id>[\w]{11,14}):\sfrom=(?<sourceAddress>[^,]+),\ssize=(?<size>[^,]+),\snrcpt=(?<nrcpt>[\w]+)\s\((?<message>(.*))\)/
  OTHER= /#{TIME_AND_PID}\s(?<queue_id>[\w]{11,14}):\s(?<data>.+)/

  REMOVED= /#{TIME_AND_PID}\s(?<queue_id>[\w]{11,14}):\sremoved/
  CONNECT= /#{TIME_AND_PID}\s:\s connect from (?<data>.+)/
  DISCONNECT= /#{TIME_AND_PID}\s:\s disconnect from (?<data>.+)/

  REG_EXPS = [TO,FROM,OTHER]
  TO_SKIP = [REMOVED,CONNECT,DISCONNECT]
end