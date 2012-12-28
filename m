Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id D2BF26B002B
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 08:43:31 -0500 (EST)
Date: Fri, 28 Dec 2012 14:43:24 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <1828895463.36547216.1356662710202.JavaMail.root@redhat.com> <50DD5FD9.2080303@redhat.com>
In-Reply-To: <50DD5FD9.2080303@redhat.com>
Message-ID: <50DDA1FC.8030608@iskon.hr>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 0000000000000500
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Johannes Weiner <jweiner@redhat.com>, mgorman@suse.de, hughd@google.com, Andrea Arcangeli <aarcange@redhat.com>, Hillf Danton <dhillf@gmail.com>, sedat.dilek@gmail.com

On 28.12.2012 10:01, Zhouping Liu wrote:
> On 12/28/2012 10:45 AM, Zhouping Liu wrote:
>>> Thank you for the report Zhouping!
>>>
>>> Would you be so kind to test the following patch and report results?
>>> Apply the patch to the latest mainline.
>> Hello Zlatko,
>>
>> I have tested the below patch(applied it on mainline directly),
>> but IMO, I'd like to say it maybe don't fix the issue completely.
>
> Hi Zlatko,
>
> I re-tested it on another machine, which has 60+ Gb RAM and 4 numa nodes,
> without your patch, it's easy to reproduce the 'NULL pointer' error,
> after applying your patch, I couldn't reproduce the issue any more.
>
> depending on the above, it implied that your patch fixed the issue.
>

Yes, that's exactly what I expected. Just wanted to doublecheck this 
time. Live and learn. ;)

> but in my last mail, I tested it on two machines, which caused hung task
> with your patch,
> so I'm confusing is it your patch block some oom-killer performance? if
> it's not, your patch is good for me.
>

 From what I know, the patch shouldn't have much influence on the oom 
killer, if any. But, as all those subsystems are closely interconnected, 
both oom & vmscan code is mm after all, there could be some 
interference. Is the hung-task issue repeatable?
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
