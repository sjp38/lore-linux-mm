Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l66HUDJM020773
	for <linux-mm@kvack.org>; Fri, 6 Jul 2007 13:30:13 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l66HUDPg266838
	for <linux-mm@kvack.org>; Fri, 6 Jul 2007 11:30:13 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l66HUDxn008516
	for <linux-mm@kvack.org>; Fri, 6 Jul 2007 11:30:13 -0600
Subject: Re: [-mm PATCH 2/8] Memory controller containers setup (v2)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20070706052103.11677.4158.sendpatchset@balbir-laptop>
References: <20070706052029.11677.16964.sendpatchset@balbir-laptop>
	 <20070706052103.11677.4158.sendpatchset@balbir-laptop>
Content-Type: text/plain
Date: Fri, 06 Jul 2007 10:30:09 -0700
Message-Id: <1183743009.10287.157.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, Eric W Biederman <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-07-05 at 22:21 -0700, Balbir Singh wrote:
> +struct mem_container {
> +	struct container_subsys_state css;
> +	/*
> +	 * the counter to account for memory usage
> +	 */
> +	struct res_counter res;
> +};

How about we call it "memory_usage"?  That would kill two birds with one
stone: get rid of the comment, and keep people from needing to refer to
the comment to figure out what "res" *IS*. 

> +/*
> + * A meta page is associated with every page descriptor. The meta page
> + * helps us identify information about the container
> + */
> +struct meta_page {
> +	struct list_head list;		/* per container LRU list */
> +	struct page *page;
> +	struct mem_container *mem_container;
> +};

Why not just rename "list" to "lru_list" or "container_lru"?

> +
> +static inline struct mem_container *mem_container_from_cont(struct container
> +								*cnt)

I'd probably break that line up differently:

static inline
struct mem_container *mem_container_from_cont(struct container *cnt)

BTW, do I see "cnt" meaning "container" now instead of "cnt"?  ;)

Is somebody's favorite dog named "cnt" and you're just trying to remind
yourself of them as often as possible?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
