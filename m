Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EFA4A6B0044
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 22:35:23 -0500 (EST)
Date: Fri, 23 Jan 2009 04:35:20 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090123033520.GC20098@wotan.suse.de>
References: <20090121143008.GV24891@wotan.suse.de> <1232560770.8025.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1232560770.8025.7.camel@localhost>
Sender: owner-linux-mm@kvack.org
To: Joe Perches <joe@perches.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 21, 2009 at 09:59:30AM -0800, Joe Perches wrote:
> One thing you might consider is that
> Q is visually close enough to O to be
> misread.
> 
> Perhaps a different letter would be good.

That's a fair point. Hugh dislikes it too, I see ;) What to do... I
had been toying with the idea that if slqb (or slub) becomes "the"
allocator, then we could rename it all back to slAb after replacing
the existing slab?

Or I could make it a 128 bit allocator and call it SLZB, which would
definitely make it "the final" allocator ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
