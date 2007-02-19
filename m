Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l1JB8SH3181300
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 22:08:29 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1JAu9q5064482
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 21:56:09 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1JAqd6H003783
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 21:52:39 +1100
Message-ID: <45D98173.6060107@in.ibm.com>
Date: Mon, 19 Feb 2007 16:22:35 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH][3/4] Add reclaim support
References: <20070219065019.3626.33947.sendpatchset@balbir-laptop> <20070219065042.3626.95544.sendpatchset@balbir-laptop> <20070219184839.db9f3bc1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070219184839.db9f3bc1.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, xemul@sw.ru, linux-mm@kvack.org, menage@google.com, svaidy@linux.vnet.ibm.com, devel@openvz.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 19 Feb 2007 12:20:42 +0530
> Balbir Singh <balbir@in.ibm.com> wrote:
> 
>> +int memctlr_mm_overlimit(struct mm_struct *mm, void *sc_cont)
>> +{
>> +	struct container *cont;
>> +	struct memctlr *mem;
>> +	long usage, limit;
>> +	int ret = 1;
>> +
>> +	if (!sc_cont)
>> +		goto out;
>> +
>> +	read_lock(&mm->container_lock);
>> +	cont = mm->container;
> 
>> +out:
>> +	read_unlock(&mm->container_lock);
>> +	return ret;
>> +}
>> +
> 
> should be
> ==
> out_and_unlock:
> 	read_unlock(&mm->container_lock);
> out_:
> 	return ret;
> 


Thanks, that's a much convention!

> 
> -Kame
> 


-- 
	Warm Regards,
	Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
