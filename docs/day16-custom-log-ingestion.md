# Day 16 — Custom Log File Ingestion

## What I Did
- Created a custom application log at /var/log/myapp/app.log
- Configured Wazuh's <localfile> section in ossec.conf to monitor it
- Verified ingestion — a generic built-in rule (2501) initially caught test content
  by coincidence, showing how generic rules can accidentally match custom logs
- Wrote a purpose-built custom rule (100016) targeting this specific log source
  using the <location> tag instead of chaining off another rule (if_sid=0)
- Confirmed rule 100016 correctly took priority over the generic match once written

## Key Config Added
ossec.conf:
```xml
<localfile>
  <log_format>syslog</log_format>
  <location>/var/log/myapp/app.log</location>
</localfile>
```

local_rules.xml:
```xml
<rule id="100016" level="10">
  <if_sid>0</if_sid>
  <location>/var/log/myapp/app.log</location>
  <match>Authentication failed</match>
  <description>MyApp: Authentication failure detected in custom application log</description>
  <group>custom_app,authentication_failed,</group>
</rule>
```

## Things I Learned
- Wazuh can monitor ANY log file via <localfile> — not just built-in system logs
- Generic built-in rules (like 2501) can accidentally match custom application
  logs if the text happens to overlap — this can be convenient but also a source
  of false positive confusion in real environments
- Using if_sid=0 with a <location> filter lets you write standalone rules for a
  specific log file without needing an existing parent rule to chain off
- Once a more specific custom rule exists for a log line, it takes priority over
  the more generic catch-all rule that might have matched otherwise
