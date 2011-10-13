Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 8E27B6B00EE
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 16:38:33 -0400 (EDT)
Date: Thu, 13 Oct 2011 16:37:08 -0400 (EDT)
Message-Id: <20111013.163708.1319779926961023813.davem@davemloft.net>
Subject: Re: [PATCH] mm: add a "struct page_frag" type containing a page,
 offset and length
From: David Miller <davem@davemloft.net>
In-Reply-To: <alpine.DEB.2.00.1110131327470.24853@chino.kir.corp.google.com>
References: <1318500176-10728-1-git-send-email-ian.campbell@citrix.com>
	<alpine.DEB.2.00.1110131327470.24853@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: ian.campbell@citrix.com, linux-kernel@vger.kernel.org, hch@infradead.org, jaxboe@fusionio.com, linux-mm@kvack.org

From: David Rientjes <rientjes@google.com>
Date: Thu, 13 Oct 2011 13:33:45 -0700 (PDT)

> On Thu, 13 Oct 2011, Ian Campbell wrote:
> 
>> A few network drivers currently use skb_frag_struct for this purpose but I have
>> patches which add additional fields and semantics there which these other uses
>> do not want.
>> 
> 
> Is this patch a part of a larger series that actually uses 
> struct page_frag?  Probably a good idea to post them so we know it doesn't 
> just lie there dormant.

See:

http://patchwork.ozlabs.org/patch/118693/
http://patchwork.ozlabs.org/patch/118694/
http://patchwork.ozlabs.org/patch/118695/
http://patchwork.ozlabs.org/patch/118700/
http://patchwork.ozlabs.org/patch/118696/
http://patchwork.ozlabs.org/patch/118699/

This is a replacement for patch #1 in that series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
