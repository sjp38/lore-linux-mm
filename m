Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1EDA16B004F
	for <linux-mm@kvack.org>; Sun, 13 Sep 2009 15:07:47 -0400 (EDT)
Date: Sun, 13 Sep 2009 20:07:05 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 0/4] compcache: in-memory compressed swapping v2
In-Reply-To: <4AAB065D.3070602@vflare.org>
Message-ID: <Pine.LNX.4.64.0909131956590.28668@sister.anvils>
References: <200909100215.36350.ngupta@vflare.org> <200909100332.55910.ngupta@vflare.org>
 <4AAB065D.3070602@vflare.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ed Tomlinson <edt@aei.ca>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc <linux-mm-cc@laptop.org>
List-ID: <linux-mm.kvack.org>

On Sat, 12 Sep 2009, Nitin Gupta wrote:
> On 09/10/2009 03:32 AM, Nitin Gupta wrote:
> > Project home: http://compcache.googlecode.com/
> >
> > * Changelog: v2 vs initial revision
> >   - Use 'struct page' instead of 32-bit PFNs in ramzswap driver and
> >   xvmalloc.
> >     This is to make these 64-bit safe.
> >   - xvmalloc is no longer a separate module and does not export any symbols.
> >     Its compiled directly with ramzswap block driver. This is to avoid any
> >     last bit of confusion with any other allocator.
> >   - set_swap_free_notify() now accepts block_device as parameter instead of
> >     swp_entry_t (interface cleanup).
> >   - Fix: Make sure ramzswap disksize matches usable pages in backing swap
> >   file.
> >     This caused initialization error in case backing swap file had
> >     intra-page
> >     fragmentation.
> 
> Can anyone please review these patches for possible inclusion in 2.6.32?

Sorry, I certainly wouldn't be able to review them for 2.6.32 myself.

Since we're already in the merge window, and this work has not yet
had exposure in mmotm (preferably) or linux-next, I really doubt
anyone should be pushing it for 2.6.32.

I'd be quite glad to see it and experiment with it in mmotm,
so it could go into 2.6.33 if all okay.  And I now fully accept
that the discard/trim situation is so hazy that you are quite
right to be asking for your own well-defined notifier instead.

But I'm not going to pretend to have reviewed it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
