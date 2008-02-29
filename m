Date: Fri, 29 Feb 2008 14:01:20 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 05/10] slub: Remove slub_nomerge
In-Reply-To: <20080229043552.282285411@sgi.com>
Message-ID: <Pine.LNX.4.64.0802291327490.11617@blonde.site>
References: <20080229043401.900481416@sgi.com> <20080229043552.282285411@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Feb 2008, Christoph Lameter wrote:
> No one has used that option for a long time and AFAICT its currently utterly
> useless.

Not so at all.  I certainly use it: not often, but from time to time,
in debugging.  If you're narrowing down on something, it's a worthwhile
tool to separate the different uses of a particular size.

And when studying slabinfo numbers, perhaps for a leak e.g. why doesn't
slabinfo doesn't show vm_area_struct, oh, it's sharing :0000088 with
cfq_queue, so we need slub_nomerge to see their actual numbers.
Perhaps I'm missing something: how does everyone else get the
right numbers without slub_nomerge?

Admittedly it's often too blunt an instrument for debugging: I'd be
happier with a debug flag which has no other side-effect than nomerge
(all the other SLUB_NEVER_MERGE flags seemed to have side-effects that
I wanted to avoid when trying to reproduce an elusive corruption),
that can be applied to a single cache as well as to the whole lot.

I could add that if you don't (or I could hack my mm/slub.c when
I need to, that's always an option: but I do think nomerge can be
useful out in the field).  If you go ahead and remove slub_nomerge,
please also remove it from Documentation/kernel-parameters.txt.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
