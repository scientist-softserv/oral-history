Delayed::Worker.destroy_failed_jobs = false

silence_warnings do
  Delayed::Job.const_set("MAX_ATTEMPTS", 10)
  Delayed::Job.const_set("MAX_RUN_TIME", 4.hours)
end
