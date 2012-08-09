Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id D9CA66B008C
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 10:51:45 -0400 (EDT)
Date: Thu, 9 Aug 2012 15:51:41 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/5] Improve hugepage allocation success rates under
 load V3
Message-ID: <20120809145141.GH12690@suse.de>
References: <1344520165-24419-1-git-send-email-mgorman@suse.de>
 <5023CADC.801@sandia.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5023CADC.801@sandia.gov>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jim Schutt <jaschut@sandia.gov>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 09, 2012 at 08:36:12AM -0600, Jim Schutt wrote:
> Hi Mel,
> 
> On 08/09/2012 07:49 AM, Mel Gorman wrote:
> >Changelog since V2
> >o Capture !MIGRATE_MOVABLE pages where possible
> >o Document the treatment of MIGRATE_MOVABLE pages while capturing
> >o Expand changelogs
> >
> >Changelog since V1
> >o Dropped kswapd related patch, basically a no-op and regresses if fixed (minchan)
> >o Expanded changelogs a little
> >
> >Allocation success rates have been far lower since 3.4 due to commit
> >[fe2c2a10: vmscan: reclaim at order 0 when compaction is enabled]. This
> >commit was introduced for good reasons and it was known in advance that
> >the success rates would suffer but it was justified on the grounds that
> >the high allocation success rates were achieved by aggressive reclaim.
> >Success rates are expected to suffer even more in 3.6 due to commit
> >[7db8889a: mm: have order>  0 compaction start off where it left] which
> >testing has shown to severely reduce allocation success rates under load -
> >to 0% in one case.  There is a proposed change to that patch in this series
> >and it would be ideal if Jim Schutt could retest the workload that led to
> >commit [7db8889a: mm: have order>  0 compaction start off where it left].
> 
> I was successful at resolving my Ceph issue on 3.6-rc1, but ran
> into some other issue that isn't immediately obvious, and prevents
> me from testing your patch with 3.6-rc1.  Today I will apply your
> patch series to 3.5 and test that way.
> 
> Sorry for the delay.
> 

No need to be sorry at all. I appreciate you taking the time and as
there were revisions since V1 you were better off waiting even if you
did not have the Ceph issue!

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
