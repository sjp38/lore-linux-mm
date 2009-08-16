Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 49B006B004D
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 13:00:10 -0400 (EDT)
Date: Sun, 16 Aug 2009 12:59:43 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
	slot is freed)
Message-ID: <20090816165943.GA26983@infradead.org>
References: <4A85E0DC.9040101@rtr.ca> <f3177b9e0908141621j15ea96c0s26124d03fc2b0acf@mail.gmail.com> <20090814234539.GE27148@parisc-linux.org> <f3177b9e0908141719s658dc79eye92ab46558a97260@mail.gmail.com> <1250341176.4159.2.camel@mulgrave.site> <4A86B69C.7090001@rtr.ca> <1250344518.4159.4.camel@mulgrave.site> <20090816150530.2bae6d1f@lxorguk.ukuu.org.uk> <20090816083434.2ce69859@infradead.org> <1250437927.3856.119.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1250437927.3856.119.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
To: James Bottomley <James.Bottomley@suse.de>
Cc: Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Mark Lord <liml@rtr.ca>, Chris Worley <worleys@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, Aug 16, 2009 at 10:52:07AM -0500, James Bottomley wrote:
> However, the enterprise has been doing UNMAP for a while, so we can draw
> inferences from them since the SSD FTL will operate similarly.  For
> them, UNMAP is the same cost in terms of time regardless of the number
> of extents.  The reason is that it's moving the blocks from the global
> in use list to the global free list.  Part of the problem is that this
> involves locking and quiescing, so UNMAP ends up being quite expensive
> to the array but constant in terms of cost (hence they want as few
> unmaps for as many sectors as possible).

How are they doing the unmaps?  Using something similar to Mark's wiper
script and using SG_IO?  Because right now we do not actually implement
UNMAP support in the kernel.  I'd really love to test the XFS batched
discard support with a real UNMAP implementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
