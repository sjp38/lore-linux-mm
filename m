Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DE7096B02A3
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 10:26:03 -0400 (EDT)
Date: Wed, 14 Jul 2010 16:25:21 +0200
From: Heinz Diehl <htd@fancy-poultry.org>
Subject: Re: [S+Q2 00/19] SLUB with queueing (V2) beats SLAB netperf TCP_RR
Message-ID: <20100714142521.GA19289@fancy-poultry.org>
References: <20100709190706.938177313@quilx.com>
 <20100710195621.GA13720@fancy-poultry.org>
 <alpine.DEB.2.00.1007121010420.14328@router.home>
 <20100712163900.GA8513@fancy-poultry.org>
 <alpine.DEB.2.00.1007121156160.18621@router.home>
 <20100713135650.GA6444@fancy-poultry.org>
 <alpine.DEB.2.00.1007132055470.14067@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1007132055470.14067@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 14.07.2010, Christoph Lameter wrote: 

> I dont see anything in there at first glance that would cause slub to
> increase its percpu usage. This is straight upstream?

Yes ,it's plain vanilla 2.6.35-rc4/-rc5 from kernel.org.

> Try to just comment out the BUILD_BUG_ON.

I first bumped it up to 24k, but that was obviously not enough, so I
commented out the BUILD_BUG_ON which triggers the build error. Now It builds
fine, and I'll do some testing.

Thanks,
Heinz.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
