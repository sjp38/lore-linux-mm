Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 15F756B005A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 06:56:29 -0500 (EST)
Date: Tue, 13 Nov 2012 11:56:24 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 12/19] mm: migrate: Introduce migrate_misplaced_page()
Message-ID: <20121113115624.GZ8218@suse.de>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
 <1352193295-26815-13-git-send-email-mgorman@suse.de>
 <20121113093644.GA21522@gmail.com>
 <20121113114344.GA26305@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121113114344.GA26305@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 13, 2012 at 12:43:44PM +0100, Ingo Molnar wrote:
> 
> * Ingo Molnar <mingo@kernel.org> wrote:
> 
> > 
> > * Mel Gorman <mgorman@suse.de> wrote:
> > 
> > > From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > > 
> > > Note: This was originally based on Peter's patch "mm/migrate: Introduce
> > > 	migrate_misplaced_page()" but borrows extremely heavily from Andrea's
> > > 	"autonuma: memory follows CPU algorithm and task/mm_autonuma stats
> > > 	collection". The end result is barely recognisable so signed-offs
> > > 	had to be dropped. If original authors are ok with it, I'll
> > > 	re-add the signed-off-bys.
> > > 
> > > Add migrate_misplaced_page() which deals with migrating pages from
> > > faults.
> > > 
> > > Based-on-work-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> > > Based-on-work-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > > Based-on-work-by: Andrea Arcangeli <aarcange@redhat.com>
> > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > ---
> > >  include/linux/migrate.h |    8 ++++
> > >  mm/migrate.c            |  104 ++++++++++++++++++++++++++++++++++++++++++++++-
> > >  2 files changed, 110 insertions(+), 2 deletions(-)
> > 
> > That's a nice patch - the TASK_NUMA_FAULT approach in the 
> > original patch was not very elegant.
> > 
> > I've started testing it to see how well your version works.
> 
> Hm, I'm seeing some instability - see the boot crash below. If I 
> undo your patch it goes away.
> 

Hah, I would not describe a "boot crash" as some instability. That's
just outright broken :)

I've not built at tree with the latest of Peter's code yet so I don't
know at this time which line it is BUG()ing on. However, it is *very*
likely that this patch is not a drop-in replacement for your tree
because IIRC, there are differences in how and when we call get_page().
That is the likely source of the snag.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
