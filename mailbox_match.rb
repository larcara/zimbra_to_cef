module MailboxMatch


  TIME_AND_PID= /(?<startTime>[\w]+\s+[\d]+\s[\d:]+)\s+(?<agentHostName>[\w]+)\s+(?<process_name>[\w\/]+)\:\s(?<deviceSeverity>[\w]+)/
  LMTP_DELIVERING = /#{TIME_AND_PID}\s+\[(?<process>[\w]+-[\d]+)\])\s\[.*\]\slmtp - Delivering message:\ssize=(?<size>[\d]+)\sbytes, nrcpts=[\d]+,\ssender=(?<sender>[\S]+@[\S]+),\smsgid=(?<eventID>[\S]+)/
  MAILBOX_ADDING = /#{TIME_AND_PID}\s+\[(?<process>[\w]+-[\d]+)\])\s\[.*\]\smailop - Adding Message:\sid=(?<message_id>[\d]+),\sMessage-ID=(?<eventID>[\S]+),\sparentId=(?<folder_id>[\d]+),\sfolderId=(?<folder_id>[\d]+),\sfolderName=(?<folder_name>[\w]+)./



  REG_EXPS = [LMTP_DELIVERING,MAILBOX_ADDING]
  TO_SKIP = []

end