Date: Thu, 29 Jul 2004 09:54:33 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
In-Reply-To: <20040728235343.GG2334@holomorphy.com>
Message-ID: <Pine.SGI.4.58.0407290952180.35081@kzerza.americas.sgi.com>
References: <Pine.SGI.4.58.0407131449330.111843@kzerza.americas.sgi.com>
 <Pine.LNX.4.44.0407132113350.8577-100000@localhost.localdomain>
 <20040728022625.249c78da.akpm@osdl.org> <20040728095925.GQ2334@holomorphy.com>
 <Pine.SGI.4.58.0407281707370.33392@kzerza.americas.sgi.com>
 <20040728235343.GG2334@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jul 2004, William Lee Irwin III wrote:

> On Wed, Jul 28, 2004 at 05:21:58PM -0500, Brent Casavant wrote:
> > The "obvious" fix is to morph the code so that the swap entries can be
> > updated in parallel to eachother and in parallel to the other miscellaneous
> > fields in the shmem_inode_info structure.  But this would be one *nasty*
> > piece of work to accomplish, much less accomplish cleanly and correctly.
> > I'm pretty sure my Linux skillset isn't up to the task, though it hasn't
> > kept me from trying.  On the upside I don't think it would significantly
> > impact performance on low processor-count systems, if we can manage to
> > do it at all.
> > I'm kind of hoping for a fairy godmother to drop in, wave her magic wand,
> > and say "Here's the quick and easy and obviously correct solution".  But
> > what're the chances of that :).
>
> This may actually have some positive impact on highly kernel-intensive
> low processor count database workloads (where kernel intensiveness makes
> up for the reduced processor count vs. the usual numerical applications
> at high processor counts on SGI systems).

Good to know.  It always amazes me how close my knowledge horizon really is.

> At the moment a number of
> stability issues have piled up that I need to take care of, but I would
> be happy to work with you on devising methods of addressing this when
> those clear up, which should be by the end of this week.

Count me in.  I've been chewing on this one for a while now, and I'll
be more than happy to help.

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
