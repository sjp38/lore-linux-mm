Received: from internal-mail-relay.corp.sgi.com (internal-mail-relay.corp.sgi.com [198.149.32.51])
	by omx3.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j9HGQEBq013823
	for <linux-mm@kvack.org>; Mon, 17 Oct 2005 09:26:14 -0700
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id j9HFZ72Z276341027
	for <linux-mm@kvack.org>; Mon, 17 Oct 2005 08:35:07 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id j9HFZ7sT96284911
	for <linux-mm@kvack.org>; Mon, 17 Oct 2005 08:35:07 -0700 (PDT)
Message-ID: <4353137A.5050705@jp.fujitsu.com>
Date: Mon, 17 Oct 2005 11:59:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH] Page eviction support in vmscan.c
References: <Pine.LNX.4.62.0510131109210.14810@schroedinger.engr.sgi.com> <434EDDCA.9010001@austin.ibm.com> <Pine.LNX.4.62.0510131524490.17853@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0510131524490.17853@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.62.0510170835000.869@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Joel Schopp <jschopp@austin.ibm.com>, lhms-devel@lists.sourceforge.net, linux-mm@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 13 Oct 2005, Joel Schopp wrote:
> 
> 
>>I'm curious what use motivated you to write it.  I think for migration it
>>would usually make more sense to let the swapper free up LRU memory and then
>>do a memory to memory migration.  But I'm not really a migration expert
> 
> 
> The motiviation was the complexity and the problems with the existing hot 
> plug implementation.
> 
> I just tried to simplify page migration as much as possible to come with 
> something that is easy to verify and that may be easily acceptable. We can 
> build on that later and incorporate more elements from the hotplug patch.
> 
Forcing pages swapped-out itself looks useful in some case.
But I think using swap in memory-hotplug is not good because of its performance.

So, this patch will not simplify memory_migrate() ;)
I think that valid direction is simplify memory_migrate() on memory.

-- Kame

> 
>>>However, swapout_pages may not be able to evict all pages for a variety of
>>>reasons.
>>
>>Have you thought about using this in combination with the fragmentation
>>avoidance patches Mel has been posting?  __GFP_USER flag that adds would go a
>>long way toward determining what can and can't be swapped out.  We use that
>>for migration with great success.  I'd assume the criteria for swapout and
>>migration are pretty similar.
> 
> 
> The patch does not determine what can and cannot be swapped out. That is 
> up to the user of the functions defined here. See my other patch that I 
> posted today for one example of a user of this patch.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
