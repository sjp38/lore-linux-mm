Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 0D6586B0006
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 16:52:52 -0400 (EDT)
Date: Fri, 12 Apr 2013 21:41:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/10] Reduce system disruption due to kswapd V2
Message-ID: <20130412204129.GA13146@suse.de>
References: <1365505625-9460-1-git-send-email-mgorman@suse.de>
 <51672331.6070605@bitsync.net>
 <20130412193947.GJ11656@suse.de>
 <5168699A.40407@bitsync.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5168699A.40407@bitsync.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zlatko Calusic <zcalusic@bitsync.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Apr 12, 2013 at 10:07:54PM +0200, Zlatko Calusic wrote:
> On 12.04.2013 21:40, Mel Gorman wrote:
> >On Thu, Apr 11, 2013 at 10:55:13PM +0200, Zlatko Calusic wrote:
> >>On 09.04.2013 13:06, Mel Gorman wrote:
> >><SNIP>
> >>
> >>- The only slightly negative thing I observed is that with the patch
> >>applied kswapd burns 10x - 20x more CPU. So instead of about 15
> >>seconds, it has now spent more than 4 minutes on one particular
> >>machine with a quite steady load (after about 12 days of uptime).
> >>Admittedly, that's still nothing too alarming, but...
> >>
> >
> >Would you happen to know what circumstances trigger the higher CPU
> >usage?
> >
> 
> Really nothing special. The server is lightly loaded, but it does
> enough reading from the disk so that pagecache is mostly populated
> and page reclaiming is active. So, kswapd is no doubt using CPU time
> gradually, nothing extraordinary.
> 
> When I sent my reply yesterday, the server uptime was 12 days, and
> kswapd had accumulated 4:28 CPU time. Now, approx 24 hours later (13
> days uptime):
> 
> root        23  0.0  0.0      0     0 ?        S    Mar30   4:52 [kswapd0]
> 

Ok, that's not too crazy.

> I will apply your v3 series soon and see if there's any improvement
> wrt CPU usage, although as I said I don't see that as a big issue.
> It's still only 0.013% of available CPU resources (dual core CPU).
> 

Excellent, thanks very much for testing and reporting back. I read your
mail on the zone balancing and FWIW I would not have expected this series
to have any impact on it. I do not have a good theory yet as to what the
problem is but I'll give it some thought and se what I come up with. I'll
be at LSF/MM next week so it might take me a while.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
