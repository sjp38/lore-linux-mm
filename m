Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 6B1A26B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 07:48:38 -0400 (EDT)
Date: Thu, 21 Mar 2013 11:48:33 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/8] Reduce system disruption due to kswapd
Message-ID: <20130321114833.GH1878@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <20130321104440.GA5053@brouette>
 <514AE6CB.2040803@bitsync.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <514AE6CB.2040803@bitsync.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zlatko Calusic <zcalusic@bitsync.net>
Cc: Linux-MM <linux-mm@kvack.org>, Damien Wyart <damien.wyart@gmail.com>

On Thu, Mar 21, 2013 at 11:54:03AM +0100, Zlatko Calusic wrote:
> On 21.03.2013 11:44, Damien Wyart wrote:
> >Hi,
> >
> >>Kswapd and page reclaim behaviour has been screwy in one way or the
> >>other for a long time. [...]
> >
> >>  include/linux/mmzone.h |  16 ++
> >>  mm/vmscan.c            | 387 +++++++++++++++++++++++++++++--------------------
> >>  2 files changed, 245 insertions(+), 158 deletions(-)
> >
> >Do you plan to respin the series with all the modifications coming from
> >the various answers applied? I've not found a git repo hosting the
> >series and I would prefer testing the most recent version.
> >
> 
> Same thing here, Mel. Thanks for the great work! I've been quite
> busy this week, but I promise to spend some time reviewing the
> patches this coming weekend. I would also appreciate if you could
> send the updated patches in the meantime. Or even better, point us
> towards the git tree where this treasure resides.
> 

Ok, I pushed the branches to a git tree at
git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git now

The mm-vmscan-limit-reclaim-v1r8 branch is the the released RFC.
The mm-vmscan-limit-reclaim-v2r1 is where things currently stand.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
