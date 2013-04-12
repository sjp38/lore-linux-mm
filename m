Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 8BA896B0002
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 15:52:08 -0400 (EDT)
Date: Fri, 12 Apr 2013 20:52:04 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/10] Reduce system disruption due to kswapd V2
Message-ID: <20130412195152.GK11656@suse.de>
References: <1365505625-9460-1-git-send-email-mgorman@suse.de>
 <51672331.6070605@bitsync.net>
 <20130412193947.GJ11656@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130412193947.GJ11656@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zlatko Calusic <zcalusic@bitsync.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Apr 12, 2013 at 08:40:04PM +0100, Mel Gorman wrote:
> On Thu, Apr 11, 2013 at 10:55:13PM +0200, Zlatko Calusic wrote:
> > On 09.04.2013 13:06, Mel Gorman wrote:
> > <SNIP>
> >
> > - The only slightly negative thing I observed is that with the patch
> > applied kswapd burns 10x - 20x more CPU. So instead of about 15
> > seconds, it has now spent more than 4 minutes on one particular
> > machine with a quite steady load (after about 12 days of uptime).
> > Admittedly, that's still nothing too alarming, but...
> > 
> 
> Would you happen to know what circumstances trigger the higher CPU
> usage?
> 

There is also a slight possibility it has been fixed in V3 by the
proportional scanning changes. In my own parallelio tests I got the
following kswapd CPU times from top.

3.9.0-rc6-vanilla           0:05.21
3.9.0-rc6-lessdisrupt-v2r11 0:07.44
3.9.0-rc6-lessdisrupt-v3r6  0:03.21

In v2, I did see slightly higher CPU usage but it was reduced in v3. For
a general set of page reclaim tests I got

3.9.0-rc6-vanilla-micro     3:09.51
3.9.0-rc6-lessdisrupt-v2r11 2:57.78
3.9.0-rc6-lessdisrupt-v3r6  1:10.05

In that case, v2 was comparable so unfortunately I was never seeing the
10-20x more CPU that you got.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
