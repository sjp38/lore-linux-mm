Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 76F136B0044
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 22:59:45 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator
From: Joe Perches <joe@perches.com>
In-Reply-To: <20090123033520.GC20098@wotan.suse.de>
References: <20090121143008.GV24891@wotan.suse.de>
	 <1232560770.8025.7.camel@localhost>  <20090123033520.GC20098@wotan.suse.de>
Content-Type: text/plain
Date: Thu, 22 Jan 2009 20:00:47 -0800
Message-Id: <1232683247.15489.103.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-01-23 at 04:35 +0100, Nick Piggin wrote:
> That's a fair point. Hugh dislikes it too, I see ;) What to do... I
> had been toying with the idea that if slqb (or slub) becomes "the"
> allocator, then we could rename it all back to slAb after replacing
> the existing slab?

maybe SLIB (slab-improved) or SLAB_NG or NSLAB or SLABX
Who says it has to be 4 letters?

> Or I could make it a 128 bit allocator and call it SLZB, which would
> definitely make it "the final" allocator ;)

That leads to the phone book game.

SLZZB - and a crystal bridge now spans the fissure.

Hmm, wrong game.

cheers, j

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
