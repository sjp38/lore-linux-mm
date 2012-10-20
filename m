Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id BAC866B005A
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 21:23:51 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id hq7so674287wib.8
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 18:23:50 -0700 (PDT)
Date: Sat, 20 Oct 2012 03:23:46 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: question on NUMA page migration
Message-ID: <20121020012345.GA24667@gmail.com>
References: <5081777A.8050104@redhat.com>
 <1350664742.2768.40.camel@twins>
 <50818A41.7030909@redhat.com>
 <1350669236.2768.66.camel@twins>
 <50819CED.30803@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50819CED.30803@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>


* Rik van Riel <riel@redhat.com> wrote:

> On 10/19/2012 01:53 PM, Peter Zijlstra wrote:
> >On Fri, 2012-10-19 at 13:13 -0400, Rik van Riel wrote:
> 
> >>Another alternative might be to do the put_page inside
> >>do_prot_none_numa().  That would be analogous to do_wp_page
> >>disposing of the old page for the caller.
> >
> >It'd have to be inside migrate_misplaced_page(), can't do before
> >isolate_lru_page() or the page might disappear. Doing it after is
> >(obviously) too late.
> 
> Keeping an extra refcount on the page might _still_
> result in it disappearing from the process by some
> other means, in-between you grabbing the refcount
> and invoking migration of the page.
> 
> >>I am not real happy about NUMA migration introducing its own
> >>migration mode...
> >
> >You didn't seem to mind too much earlier, but I can remove it if you
> >want.
> 
> Could have been reviewing fatigue :)

:-)

> And yes, it would have been nice to not have a special
> migration mode for sched/numa.
> 
> Speaking of, when do you guys plan to submit a (cleaned up)
> version of the sched/numa patch series for review on lkml?

Which commit(s) worry you specifically?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
