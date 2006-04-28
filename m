Date: Fri, 28 Apr 2006 16:01:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/7] page migration: Reorder functions in migrate.c
In-Reply-To: <20060428150806.057b0bac.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0604281556220.3412@schroedinger.engr.sgi.com>
References: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
 <20060428150806.057b0bac.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, lee.schermerhorn@hp.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 28 Apr 2006, Andrew Morton wrote:
> I'm a bit concerned about the way these migration patches are shaping up.
> 
> - There was quite a lot of rework against the initial batch of "swapless"
>   patches.  I haven't yet found the time to sit down and review the end
>   result.
> 
> - The initial batch of "swapless" patches needed a whole barrage of
>   fixups to make the kernel compile.

The barrage came in because there was additional functionality proposed. 
The read/write entry support incomplete and required additional code 
to fix paths that may touch locked pages. If this functionality is too 
problematic then the read/write support could be dropped.

> - The patch series is rather straggly now: later patches are fixing up
>   code which was added in multiple earlier patches, so refactoring it all
>   logically is non-trivial.

Hmm... Yes there is quite a bit that accumulated. There are a number of 
patches that were done in order to reorganize the code.
 
> - I have vague feelings of disquiet regarding the whole thing and would
>   like to find the time to sit down and take a closer look at what's going
>   on in there.  This is a bit hard with the patches factored as they are
>   now.

> So I'm thinking it'd be good (for me, at least) if I were to drop the lot
> and ask you to refactor the patch series back into a logical sequence, make
> sure all the fixups are folded into the right places so we can generally
> take a fresh look at what you're proposing.
> 
> How hurtful would that be?

Not too difficult if I have a tree to patch against.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
