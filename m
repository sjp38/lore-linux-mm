Date: Tue, 13 Jul 2004 17:27:34 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
In-Reply-To: <Pine.LNX.4.44.0407132113350.8577-100000@localhost.localdomain>
Message-ID: <Pine.SGI.4.58.0407131722250.111843@kzerza.americas.sgi.com>
References: <Pine.LNX.4.44.0407132113350.8577-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2004, Hugh Dickins wrote:

> On Tue, 13 Jul 2004, Brent Casavant wrote:

> > Assuming this is correct, I imagine I should just snag the next
> > bit in the flags field (bit 0 is SHMEM_PAGEIN (== VM_READ) and
> > bit 1 is SHMEM_TRUNCATE (== VM_WRITE), I'd use bit 2 for
> > SHMEM_NOACCT (== VM_EXEC)) and run with this idea, right?
>
> Yes, go ahead, though it's getting more and more embarrassing that I
> started out reusing VM_ACCOUNT within shmem.c, it should now have its
> own set of flags: let me tidy that up once you're done.  (Something
> else I should do for your scalability is stop putting everything on
> on the shmem_inodes list: that's only needed when pages are on swap.)
>
> But please don't call the new one SHMEM_NOACCT: ACCT or ACCOUNT refers
> to the security_vm_enough_memory/vm_unacct_memory stuff throughout,
> and _that_ accounting does still apply to these /dev/zero files.
>
> Hmm, I was about to suggest SHMEM_NOSBINFO,
> but how about really no sbinfo, just NULL sbinfo?

OK, I gave this a try (calling it SHMEM_NOSBINFO).  It seems to work
functionally.  I can't get time on our 512P until tomorrow morning (CDT),
so I'll hold off on the patch until I've seen that it really fixes the
problem.

I'd really like to volunteer to do the work to have a NULL sbinfo
entirely.  But that might take a lot more time to accomplish as
I'm still puzzled by how all these pieces interact.

Thanks,
Brent

-- 
Brent Casavant             bcasavan@sgi.com        Forget bright-eyed and
Operating System Engineer  http://www.sgi.com/     bushy-tailed; I'm red-
Silicon Graphics, Inc.     44.8562N 93.1355W 860F  eyed and bushy-haired.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
