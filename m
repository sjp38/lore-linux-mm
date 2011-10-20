Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 596B76B002D
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 05:00:49 -0400 (EDT)
Date: Thu, 20 Oct 2011 04:59:33 -0400 (EDT)
Message-Id: <20111020.045933.1246070642138310107.davem@davemloft.net>
Subject: Re: [PATCH] mm: add a "struct page_frag" type containing a page,
 offset and length
From: David Miller <davem@davemloft.net>
In-Reply-To: <1318927778.16132.52.camel@zakaz.uk.xensource.com>
References: <20111013142201.355f9afc.akpm@linux-foundation.org>
	<1318575363.11016.8.camel@dagon.hellion.org.uk>
	<1318927778.16132.52.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian.Campbell@citrix.com
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-kernel@vger.kernel.org, hch@infradead.org, jaxboe@fusionio.com, linux-mm@kvack.org

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Tue, 18 Oct 2011 09:49:38 +0100

> Subject: [PATCH] mm: add a "struct page_frag" type containing a page, offset and length
> 
> A few network drivers currently use skb_frag_struct for this purpose but I have
> patches which add additional fields and semantics there which these other uses
> do not want.
> 
> A structure for reference sub-page regions seems like a generally useful thing
> so do so instead of adding a network subsystem specific structure.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Acked-by: Jens Axboe <jaxboe@fusionio.com>
> Acked-by: David Rientjes <rientjes@google.com>

Applied, thanks Ian.

Please respin your skbfrag patches.

Thanks again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
