Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id mA89oGfj019969
	for <linux-mm@kvack.org>; Sat, 8 Nov 2008 20:50:16 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA89o6Nk3981312
	for <linux-mm@kvack.org>; Sat, 8 Nov 2008 20:50:07 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA89o0Yn010886
	for <linux-mm@kvack.org>; Sat, 8 Nov 2008 20:50:01 +1100
Message-ID: <491560C0.50400@linux.vnet.ibm.com>
Date: Sat, 08 Nov 2008 15:19:52 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][mm] [PATCH 4/4] Memory cgroup hierarchy feature selector
 (v2)
References: <20081108091009.32236.26177.sendpatchset@localhost.localdomain> <20081108091113.32236.12390.sendpatchset@localhost.localdomain> <49155E45.3030704@cn.fujitsu.com>
In-Reply-To: <49155E45.3030704@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Li Zefan wrote:
>> +static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
>> +					u64 val)
>> +{
>> +	int retval = 0;
>> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
>> +
>> +	if (val == 1) {
>> +		if (list_empty(&cont->children))
> 
> cgroup_lock should be held before checking cont->children.
> 

Good point, I'll look at that aspect

>> +			mem->use_hierarchy = val;
>> +		else
>> +			retval = -EBUSY;
>> +	} else if (val == 0) {
> 
> And code duplicate.

Yes, this can be optimized better. I'll fix that in v3.

> 
>> +		if (list_empty(&cont->children))
>> +			mem->use_hierarchy nn= val;
>> +		else
>> +			retval = -EBUSY;
>> +	} else
>> +		retval = -EINVAL;
>> +
>> +	return retval;
>> +}
>> +
> 


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
