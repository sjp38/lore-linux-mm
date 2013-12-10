Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f49.google.com (mail-oa0-f49.google.com [209.85.219.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2DC486B004D
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 02:18:02 -0500 (EST)
Received: by mail-oa0-f49.google.com with SMTP id i4so5030401oah.8
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 23:18:01 -0800 (PST)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id so9si2223393oeb.140.2013.12.09.23.17.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 23:18:01 -0800 (PST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 12:47:50 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 07BD4E0056
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 12:50:04 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBA7HgpC3473800
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 12:47:42 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBA7Hjdt007203
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 12:47:45 +0530
Date: Tue, 10 Dec 2013 15:17:43 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 12/12] sched/numa: drop local 'ret' in
 task_numa_migrate()
Message-ID: <52a6c029.c9903c0a.2486.216cSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386483293-15354-12-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386659567-rn8hjtqh-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386659567-rn8hjtqh-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Naoya,
On Tue, Dec 10, 2013 at 02:12:47AM -0500, Naoya Horiguchi wrote:
>On Sun, Dec 08, 2013 at 02:14:53PM +0800, Wanpeng Li wrote:
>> task_numa_migrate() has two locals called "ret". Fix it all up.
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
>Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>

How about patch7~8? 

Regards,
Wanpeng Li 

>Thanks!
>Naoya
>
>> ---
>>  kernel/sched/fair.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>> 
>> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
>> index df8b677..3159ca7 100644
>> --- a/kernel/sched/fair.c
>> +++ b/kernel/sched/fair.c
>> @@ -1257,7 +1257,7 @@ static int task_numa_migrate(struct task_struct *p)
>>  	p->numa_scan_period = task_scan_min(p);
>>  
>>  	if (env.best_task == NULL) {
>> -		int ret = migrate_task_to(p, env.best_cpu);
>> +		ret = migrate_task_to(p, env.best_cpu);
>>  		return ret;
>>  	}
>>  
>> -- 
>> 1.7.5.4
>> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
