Date: Fri, 24 May 2002 04:42:34 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC][PATCH] using page aging to shrink caches (pre8-ac5)
Message-ID: <20020524114234.GJ14918@holomorphy.com>
References: <200205180010.51382.tomlins@cam.org> <20020521144759.B1153@redhat.com> <200205240728.45558.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <200205240728.45558.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2002 at 07:28:45AM -0400, Ed Tomlinson wrote:
> This moves things towards having the vm do the work of freeing the
> pages. I do wonder if it worth the effort in that slab pages are a
> bit different from other pages and get treated a little differently.
> For instance, we sometimes free slab pages in refill_inactive.
> Without this the caches can grow and grow without any possibility of
> shrinking when under low loads.  By allowing freeing we avoid getting
> into a situation where slab pages cause an artificial shortage.
> Finding a good method of handling the dcache/icache and dquota caches
> has been fun...  What I do now is factor the pruning and shrinking
> into different calls.  The puning, in effect, ages entries in the
> above caches. The rate I prune is simply the rate I see entries for
> these slabs in refill_inactive_zone. This is seems fair and, in my
> testing, works better than anything else I have tried (I have have
> experimented quite a bit).  It also avoid using any magic numbers 
> and is self tuning.

This kind of cache reclamation logic is so sorely needed it's
unimaginable. I'm quite grateful for your efforts in this direction,
and hope to be able to provide some assistance in testing soon.

Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
