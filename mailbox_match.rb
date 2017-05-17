module MailboxMatch


  module Syslog
    TIME_AND_PID= /(?<event_time>[\w]+\s+[\d]+\s[\d:]+)\s+(?<host_name>[\w]+)\s+(?<process_name>[\w\/]+)\:\s(?<severity>[\w]+)/
    LMTP_DELIVERING = /#{TIME_AND_PID}\s+\[(?<process>[\w]+-[\d]+)\]\s\[.*\]\slmtp - Delivering message:\ssize=(?<size>[\d]+)\sbytes, nrcpts=[\d]+,\ssender=(?<sender>[\S]+@[\S]+),\smsgid=(?<mail_message_id>[\S]+)/
    MAILBOX_ADDING =  /#{TIME_AND_PID}\s+\[(?<process>[\w|\d]+)-[\d]+(:\/\/.*\/service\/soap\/(?<soap_action>[\S]+))?\]\s\[.*\]\smailop - Adding Message:\sid=(?<zimbra_message_id>[\d]+),\sMessage-ID=(?<mail_message_id>[\S]+),\sparentId=(?<parent_id>[-|\d]+),\sfolderId=(?<folder_id>[\d]+),\sfolderName=(?<folder_name>[\w]+)./
    SENDIG_TO_MTA = /#{TIME_AND_PID}\s+\[(?<process>[\w|\d]+)-[\d]+(:\/\/.*\/service\/soap\/(?<soap_action>[\S]+))?\]\s\[.*\]\ssmtp - Sending message to MTA at localhost:\sMessage-ID=(?<mail_message_id>[\S]+),\sreplyType=(?<reply_type>[\S]+)/
    REG_EXPS = [LMTP_DELIVERING,MAILBOX_ADDING,SENDIG_TO_MTA]
    TO_SKIP = []

  end
##SYSLOG SCHEMA


##STANDARD SCHEMA
  TIME_AND_PID= /(?<event_time>[\d-]+\s[\d:,]+)\s(?<deviceSeverity>[\w]+)/
  LMTP_DELIVERING = /#{TIME_AND_PID}\s+\[(?<process>[\w]+-[\d]+)\]\s\[.*\]\slmtp - Delivering message:\ssize=(?<size>[\d]+)\sbytes, nrcpts=[\d]+,\ssender=(?<sender>[\S]+@[\S]+),\smsgid=(?<mail_message_id>[\S]+)/
  MAILBOX_ADDING =  /#{TIME_AND_PID}\s+\[(?<process>[\w|\d]+)-[\d]+(:\/\/.*\/service\/soap\/(?<soap_action>[\S]+))?\]\s\[.*\]\smailop - Adding Message:\sid=(?<zimbra_message_id>[\d]+),\sMessage-ID=(?<mail_message_id>[\S]+),\sparentId=(?<parent_id>[-|\d]+),\sfolderId=(?<folder_id>[\d]+),\sfolderName=(?<folder_name>[\w]+)./
  SENDIG_TO_MTA = /#{TIME_AND_PID}\s+\[(?<process>[\w|\d]+)-[\d]+(:\/\/.*\/service\/soap\/(?<soap_action>[\S]+))?\]\s\[.*\]\ssmtp - Sending message to MTA at localhost:\sMessage-ID=(?<mail_message_id>[\S]+),\sreplyType=(?<reply_type>[\S]+)/


  REG_EXPS = [LMTP_DELIVERING,MAILBOX_ADDING,SENDIG_TO_MTA]
  TO_SKIP = []

end