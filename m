Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 741F56B0171
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 16:53:00 -0400 (EDT)
Date: Thu, 13 Oct 2011 16:51:48 -0400 (EDT)
Message-Id: <20111013.165148.64222593458932960.davem@davemloft.net>
Subject: Re: [PATCH] mm: add a "struct page_frag" type containing a page,
 offset and length
From: David Miller <davem@davemloft.net>
In-Reply-To: <alpine.DEB.2.00.1110131348310.24853@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1110131327470.24853@chino.kir.corp.google.com>
	<20111013.163708.1319779926961023813.davem@davemloft.net>
	<alpine.DEB.2.00.1110131348310.24853@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: akpm@linux-foundation.org, ian.campbell@citrix.com, linux-kernel@vger.kernel.org, hch@infradead.org, jaxboe@fusionio.com, linux-mm@kvack.org

From: David Rientjes <rientjes@google.com>
Date: Thu, 13 Oct 2011 13:49:35 -0700 (PDT)

> On Thu, 13 Oct 2011, David Miller wrote:
> 
>> >> A few network drivers currently use skb_frag_struct for this purpose but I have
>> >> patches which add additional fields and semantics there which these other uses
>> >> do not want.
>> >> 
>> > 
>> > Is this patch a part of a larger series that actually uses 
>> > struct page_frag?  Probably a good idea to post them so we know it doesn't 
>> > just lie there dormant.
>> 
>> See:
>> 
>> http://patchwork.ozlabs.org/patch/118693/
>> http://patchwork.ozlabs.org/patch/118694/
>> http://patchwork.ozlabs.org/patch/118695/
>> http://patchwork.ozlabs.org/patch/118700/
>> http://patchwork.ozlabs.org/patch/118696/
>> http://patchwork.ozlabs.org/patch/118699/
>> 
>> This is a replacement for patch #1 in that series.
>> 
> 
> Ok, let's add Andrew to the thread so this can go through -mm in 
> preparation for that series.

It doesn't usually work like that, net-next is usually one of the first
trees that Stephen pulls into -next, so this kind of simple dependency should
go into my tree if the -mm developers give it an ACK and are OK with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
