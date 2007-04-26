Date: Thu, 26 Apr 2007 15:07:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] change global zonelist order on NUMA v2
In-Reply-To: <1177624660.5705.72.camel@localhost>
Message-ID: <Pine.LNX.4.64.0704261504090.19704@schroedinger.engr.sgi.com>
References: <20070426183417.058f6f9e.kamezawa.hiroyu@jp.fujitsu.com>
 <1177624660.5705.72.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, AKPM <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Apr 2007, Lee Schermerhorn wrote:

> Against 2.6.21-rc7 atop KAMEZAWA Hiroyuki's "change global zonelist
> order on NUMA v2" patch.

Hmmm.. hmmm... serious hackery here. Isnt there some way to simplify the 
core impact and make the arch select a strategy? A boot option would be
less impact (I am a bit concerned about switching zonelist mid stream).

The arch should be able to specify a default zone order. So the best thing 
would be to make the zone orders configurable in the page allocator and 
then have the arch code determine a default order depending on the 
hardware that we are running on.

Make sure that the !CONFIG_ZONE_DMA case works.

What about ZONE_DMA32 support?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
