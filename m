From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Additional features for zone reclaim
Date: Wed, 18 Jan 2006 03:55:54 +0100
References: <Pine.LNX.4.62.0601171507580.28915@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0601171507580.28915@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200601180355.55001.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 18 January 2006 00:10, Christoph Lameter wrote:
> This patch adds the ability to shrink the cache if a zone runs out of
> memory or to start swapping out pages on a node. The slab shrink
> has some issues since it is global and not related to the zone.
> One could add support for zone specifications to the shrinker to
> make that work. Got a patch halfway done that would modify all
> shrinkers to take an additional zone parameters. But is that worth it?

I was considering this when I was working on NUMA memory policy
because the VM often got unhappy with MPOL_BIND under stress.
Didn't do it to keep the patches simple, but it would be probably a good 
thing.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
