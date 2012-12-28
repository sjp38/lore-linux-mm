Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 42D246B002B
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 07:57:38 -0500 (EST)
Date: Fri, 28 Dec 2012 13:57:31 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <1828895463.36547216.1356662710202.JavaMail.root@redhat.com>
In-Reply-To: <1828895463.36547216.1356662710202.JavaMail.root@redhat.com>
Message-ID: <50DD973B.8000101@iskon.hr>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 0000000000000500
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Johannes Weiner <jweiner@redhat.com>, mgorman@suse.de, hughd@google.com, Andrea Arcangeli <aarcange@redhat.com>, Hillf Danton <dhillf@gmail.com>, sedat.dilek@gmail.com

On 28.12.2012 03:45, Zhouping Liu wrote:
>>
>> Thank you for the report Zhouping!
>>
>> Would you be so kind to test the following patch and report results?
>> Apply the patch to the latest mainline.
>
> Hello Zlatko,
>
> I have tested the below patch(applied it on mainline directly),
> but IMO, I'd like to say it maybe don't fix the issue completely.
>
> run the reproducer[1] on two machine, one machine has 2 numa nodes(8Gb RAM),
> another one has 4 numa nodes(8Gb RAM), then the system hung all the time, such as the dmesg log:
>
> [  713.066937] Killed process 6085 (oom01) total-vm:18880768kB, anon-rss:7915612kB, file-rss:4kB
> [  959.555269] INFO: task kworker/13:2:147 blocked for more than 120 seconds.
> [  959.562144] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 1079.382018] INFO: task kworker/13:2:147 blocked for more than 120 seconds.
> [ 1079.388872] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 1199.209709] INFO: task kworker/13:2:147 blocked for more than 120 seconds.
> [ 1199.216562] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 1319.036939] INFO: task kworker/13:2:147 blocked for more than 120 seconds.
> [ 1319.043794] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 1438.864797] INFO: task kworker/13:2:147 blocked for more than 120 seconds.
> [ 1438.871649] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 1558.691611] INFO: task kworker/13:2:147 blocked for more than 120 seconds.
> [ 1558.698466] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> ......
>
> I'm not sure whether it's your patch triggering the hung task or not, but reverted cda73a10eb3,
> the reproducer(oom01) can PASS without both 'NULL pointer dereference at 0000000000000500' and hung task issues.
>
> but some time, it's possible that the reproducer(oom01) cause hung task on a box with large RAM(100Gb+), so I can't judge it...
>

Thanks for the test.

Yes, close to OOM things get quite unstable and it's hard to get 
reliable test results. Maybe you could run it a few times, and see if 
you can get any meaningful statistics out of a few runs. I need to check 
oom.c myself and see what it's doing. Thanks for the link.

Regards,
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
