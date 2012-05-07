Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id EEBBC6B0083
	for <linux-mm@kvack.org>; Mon,  7 May 2012 14:22:52 -0400 (EDT)
Date: Mon, 07 May 2012 14:21:43 -0400 (EDT)
Message-Id: <20120507.142143.172247040163546224.davem@davemloft.net>
Subject: Re: [patch 10/10] mm: remove sparsemem allocation details from the
 bootmem allocator
From: David Miller <davem@davemloft.net>
In-Reply-To: <20120507181941.GF19417@google.com>
References: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
	<1336390672-14421-11-git-send-email-hannes@cmpxchg.org>
	<20120507181941.GF19417@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, shangw@linux.vnet.ibm.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Tejun Heo <tj@kernel.org>
Date: Mon, 7 May 2012 11:19:41 -0700

> On Mon, May 07, 2012 at 01:37:52PM +0200, Johannes Weiner wrote:
>> alloc_bootmem_section() derives allocation area constraints from the
>> specified sparsemem section.  This is a bit specific for a generic
>> memory allocator like bootmem, though, so move it over to sparsemem.
>> 
>> As __alloc_bootmem_node_nopanic() already retries failed allocations
>> with relaxed area constraints, the fallback code in sparsemem.c can be
>> removed and the code becomes a bit more compact overall.
>> 
>> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> For 03-10
> 
>  Acked-by: Tejun Heo <tj@kernel.org>
> 
> Thanks for doing this.  While at it, maybe we can clear up the naming
> mess there?  I don't hate __s too much but the bootmem allocator
> brings it to a whole new level.  :(

+1  And you can add my Ack to this series too, thanks Johannes:

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
