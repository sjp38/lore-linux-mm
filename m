Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m5PNqC17016238
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 09:52:12 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5PNqPIK289066
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 09:52:25 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5PNqPWo013282
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 09:52:25 +1000
Message-ID: <4862DA32.2070102@linux.vnet.ibm.com>
Date: Thu, 26 Jun 2008 05:22:18 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [1/2] memrlimit handle attach_task() failure, add can_attach()
 callback
References: <20080620150132.16094.29151.sendpatchset@localhost.localdomain> <20080620150142.16094.48612.sendpatchset@localhost.localdomain> <20080625163753.6039c46b.akpm@linux-foundation.org>
In-Reply-To: <20080625163753.6039c46b.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: yamamoto@valinux.co.jp, menage@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Fri, 20 Jun 2008 20:31:42 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> +/*
>> + * Add the value val to the resource counter and check if we are
>> + * still under the limit.
>> + */
>> +static inline bool res_counter_add_check(struct res_counter *cnt,
>> +						unsigned long val)
>> +{
>> +	bool ret = false;
>> +	unsigned long flags;
>> +
>> +	spin_lock_irqsave(&cnt->lock, flags);
>> +	if (cnt->usage + val <= cnt->limit)
>> +		ret = true;
>> +	spin_unlock_irqrestore(&cnt->lock, flags);
>> +	return ret;
>> +}
> 
> The comment and the function name imply that thins function will "Add
> the value val to the resource counter".  But it doesn't do that at all.
> In fact the first arg could be a `const struct res_counter *'.
> 
> Perhaps res_counter_can_add() would be more accurate.

Will fix both problems and send out fixes. I intended to call it
res_counter_check_and_add(), but I don't like "and" in function names.
res_counter_can_add is definitely better.


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
