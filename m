Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8CD666B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 21:44:10 -0400 (EDT)
Received: by oixx17 with SMTP id x17so87109133oix.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 18:44:10 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id f6si3267541obt.30.2015.09.14.18.44.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 14 Sep 2015 18:44:09 -0700 (PDT)
Message-ID: <55F775C1.6010808@huawei.com>
Date: Tue, 15 Sep 2015 09:34:57 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] numa-balancing: fix confusion in /proc/sys/kernel/numa_balancing
References: <55F6684F.4010007@huawei.com> <20150914074317.GA8966@gmail.com>
In-Reply-To: <20150914074317.GA8966@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, zhongjiang@huawei.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/9/14 15:43, Ingo Molnar wrote:

> 
> * Xishi Qiu <qiuxishi@huawei.com> wrote:
> 
>> We can only echo 0 or 1 > "/proc/sys/kernel/numa_balancing", usually 1 means
>> enable and 0 means disable. But when echo 1, it shows the value is 65536, this
>> is confusion.
>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>> ---
>>  kernel/sched/core.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
>> index 3595403..e97a348 100644
>> --- a/kernel/sched/core.c
>> +++ b/kernel/sched/core.c
>> @@ -2135,7 +2135,7 @@ int sysctl_numa_balancing(struct ctl_table *table, int write,
>>  {
>>  	struct ctl_table t;
>>  	int err;
>> -	int state = numabalancing_enabled;
>> +	int state = !!numabalancing_enabled;
>>  
>>  	if (write && !capable(CAP_SYS_ADMIN))
>>  		return -EPERM;
> 
> So in the latest scheduler tree this variable got renamed, please adjust your 
> patch:
> 
>   git git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git sched/core
> 

Hi Ingo,

I tested the latest kernel in the above tree, it seems that the problem has
been fixed. So please drop this patch.

Thanks,
Xishi Qiu

> 
> Thanks,
> 
> 	Ingo
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
