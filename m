Date: Wed, 28 Jul 2004 16:53:34 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
Message-ID: <20040728235334.GF2334@holomorphy.com>
References: <Pine.SGI.4.58.0407131449330.111843@kzerza.americas.sgi.com> <Pine.LNX.4.44.0407132113350.8577-100000@localhost.localdomain> <20040728022625.249c78da.akpm@osdl.org> <20040728095925.GQ2334@holomorphy.com> <Pine.SGI.4.58.0407281707370.33392@kzerza.americas.sgi.com> <20040728160537.57c8c85b.akpm@osdl.org> <Pine.SGI.4.58.0407281821040.33392@kzerza.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.SGI.4.58.0407281821040.33392@kzerza.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 28, 2004 at 06:40:40PM -0500, Brent Casavant wrote:
> Well, it's really not even a common workload for tmpfs-backed-shm, where
> common means "non-HPC".  Where SGI ran into this problem is with MPI
> startup.  Our workaround at this time is to replace one large /dev/zero
> mapping shared amongst many forked processes (e.g. one process per CPU)
> with a bunch of single-page mappings of the same total size.  This
> apparently has the effect of breaking the mapping up into multiple inodes,
> and reduces contention for any particular inode lock.
> But that's an ugly hack, and we really want to get rid of it.  I may be
> talking out my rear, but I suspect that this will cause issues elsewhere
> (e.g. lots of tiny VM regions to track, which can be painful at
> fork/exec/exit time [if my IRIX experience serves me well]).  I can look
> into the specifics of the workaround and probably provide numbers if
> anyone is really interested in such things at this point.

I'm very interested. I have similar issues with per-inode locks in other
contexts. This one is bound to factor in as well.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
