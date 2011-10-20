Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9BEBF6B002E
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 05:04:42 -0400 (EDT)
Subject: Re: [PATCH] mm: add a "struct page_frag" type containing a page,
 offset and length
From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Thu, 20 Oct 2011 10:04:39 +0100
In-Reply-To: <20111020.045933.1246070642138310107.davem@davemloft.net>
References: <20111013142201.355f9afc.akpm@linux-foundation.org>
	 <1318575363.11016.8.camel@dagon.hellion.org.uk>
	 <1318927778.16132.52.camel@zakaz.uk.xensource.com>
	 <20111020.045933.1246070642138310107.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Message-ID: <1319101479.3385.131.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rientjes@google.com" <rientjes@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "jaxboe@fusionio.com" <jaxboe@fusionio.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 2011-10-20 at 09:59 +0100, David Miller wrote:
> From: Ian Campbell <Ian.Campbell@citrix.com>
> Date: Tue, 18 Oct 2011 09:49:38 +0100
> 
> > Subject: [PATCH] mm: add a "struct page_frag" type containing a page, offset and length
> > 
> > A few network drivers currently use skb_frag_struct for this purpose but I have
> > patches which add additional fields and semantics there which these other uses
> > do not want.
> > 
> > A structure for reference sub-page regions seems like a generally useful thing
> > so do so instead of adding a network subsystem specific structure.
> > 
> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> > Acked-by: Jens Axboe <jaxboe@fusionio.com>
> > Acked-by: David Rientjes <rientjes@google.com>
> 
> Applied, thanks Ian.
> 
> Please respin your skbfrag patches.

I think I must've hit send on the respin at about the same time you hit
send on your mail...

> 
> Thanks again.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
