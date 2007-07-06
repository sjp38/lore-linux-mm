Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l66LUJoh179892
	for <linux-mm@kvack.org>; Sat, 7 Jul 2007 07:30:19 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l66LAvwV207178
	for <linux-mm@kvack.org>; Sat, 7 Jul 2007 07:10:57 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l66L7OCC022396
	for <linux-mm@kvack.org>; Sat, 7 Jul 2007 07:07:25 +1000
Message-ID: <468EAF07.8000902@linux.vnet.ibm.com>
Date: Fri, 06 Jul 2007 14:07:19 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm PATCH 2/8] Memory controller containers setup (v2)
References: <20070706052029.11677.16964.sendpatchset@balbir-laptop> <20070706052103.11677.4158.sendpatchset@balbir-laptop> <1183743009.10287.157.camel@localhost>
In-Reply-To: <1183743009.10287.157.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, Eric W Biederman <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Thu, 2007-07-05 at 22:21 -0700, Balbir Singh wrote:
>> +struct mem_container {
>> +	struct container_subsys_state css;
>> +	/*
>> +	 * the counter to account for memory usage
>> +	 */
>> +	struct res_counter res;
>> +};
> 
> How about we call it "memory_usage"?  That would kill two birds with one
> stone: get rid of the comment, and keep people from needing to refer to
> the comment to figure out what "res" *IS*. 
> 

Hmm.. res is the closest to resource counter. res_cnt is confusing.
res is a generic resource definition to indicate that we are dealing
with generic resource counters.

>> +/*
>> + * A meta page is associated with every page descriptor. The meta page
>> + * helps us identify information about the container
>> + */
>> +struct meta_page {
>> +	struct list_head list;		/* per container LRU list */
>> +	struct page *page;
>> +	struct mem_container *mem_container;
>> +};
> 
> Why not just rename "list" to "lru_list" or "container_lru"?
> 

I think just lru might be fine, meta_page->lru == container LRU.

>> +
>> +static inline struct mem_container *mem_container_from_cont(struct container
>> +								*cnt)
> 
> I'd probably break that line up differently:
> 
> static inline
> struct mem_container *mem_container_from_cont(struct container *cnt)
> 

Yes, that's better.

> BTW, do I see "cnt" meaning "container" now instead of "cnt"?  ;)
> 

Nope, I'll fix it to be cont

> Is somebody's favorite dog named "cnt" and you're just trying to remind
> yourself of them as often as possible?
> 

It's an easy shorthands to use, like i or ref, num.

> -- Dave
> 


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
