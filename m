Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id B6B876B005A
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 17:40:51 -0500 (EST)
Received: by mail-da0-f43.google.com with SMTP id u36so1743029dak.2
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 14:40:50 -0800 (PST)
Date: Thu, 20 Dec 2012 14:40:59 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] ksm: make rmap walks more scalable
In-Reply-To: <CA+55aFxfS0SBbRBRULX4Hm7a-xOY7ebJ=Ncu2cAdH2xvcZFO+Q@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1212201438190.977@eggly.anvils>
References: <alpine.LNX.2.00.1212191735530.25409@eggly.anvils> <alpine.LNX.2.00.1212191742440.25409@eggly.anvils> <50D387FD.4020008@oracle.com> <CA+55aFxfS0SBbRBRULX4Hm7a-xOY7ebJ=Ncu2cAdH2xvcZFO+Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Petr Holasek <pholasek@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Thu, 20 Dec 2012, Linus Torvalds wrote:
> On Thu, Dec 20, 2012 at 1:49 PM, Sasha Levin <sasha.levin@oracle.com> wrote:
> > On 12/19/2012 08:44 PM, Hugh Dickins wrote:
> >> The rmap walks in ksm.c are like those in rmap.c:
> >> they can safely be done with anon_vma_lock_read().
> >>
> >> Signed-off-by: Hugh Dickins <hughd@google.com>
> >> ---
> >
> > Hi Hugh,
> >
> > This patch didn't fix the ksm oopses I'm seeing.
> >
> > This is with both patches applied:
> 
> Looks like another NULL mm pointer in ksmd.. Hugh fixed one in
> 2832bc19f666 ("sched: numa: ksm: fix oops in task_numa_placment()"),
> this looks like more of the same.
> 
> At a guess, it looks like get_mergeable_page() has a rmap_item with no
> mm. No idea how that happened. Hugh? Some race due to something that
> depended on the mmap_sem being exclusive, rather than for
> read-ownership?

No, it's just a misunderstanding: Sasha's problem is with a linux-next
that has Petr's NUMA KSM patch in, and we're still ironing known issues
out of that one.  Not a problem for 3.8-rc1.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
