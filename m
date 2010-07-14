Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 89A306B02A4
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 07:51:54 -0400 (EDT)
Message-ID: <4C3DA4B9.1060206@kernel.org>
Date: Wed, 14 Jul 2010 13:51:21 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [S+Q2 00/19] SLUB with queueing (V2) beats SLAB netperf TCP_RR
References: <20100709190706.938177313@quilx.com> <20100710195621.GA13720@fancy-poultry.org> <alpine.DEB.2.00.1007121010420.14328@router.home> <20100712163900.GA8513@fancy-poultry.org> <alpine.DEB.2.00.1007121156160.18621@router.home> <20100713135650.GA6444@fancy-poultry.org> <alpine.DEB.2.00.1007132055470.14067@router.home>
In-Reply-To: <alpine.DEB.2.00.1007132055470.14067@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Heinz Diehl <htd@fancy-poultry.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello,

On 07/14/2010 04:01 AM, Christoph Lameter wrote:
> I dont see anything in there at first glance that would cause slub to
> increase its percpu usage. This is straight upstream?

It's basically checking constant expressions there and
PERCPU_DYNAMIC_EARLY_SIZE is defined as 12k, so slub is thinking that
it's gonna use more memory on that build.

> Try to just comment out the BUILD_BUG_ON. I had it misfire before and
> fixed the formulae to no longer give false positives. Maybe that is
> another case. Tejun wanted that but never was able to give me an exact
> formular to check for.

Yeah, unfortunately, due to alignment requirements, it can't be
determined with accuracy.  We'll just have to size it sufficiently.

> At the Ottawa Linux Symposium right now so responses may be delayed.
> Hotels Internet connection keeps getting clogged for some reason.

I'm in suse labs conf until next week so I don't think I'll be doing
much till then either.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
