Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 676916B0005
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 07:20:24 -0400 (EDT)
Date: Thu, 21 Mar 2013 11:20:21 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/8] Reduce system disruption due to kswapd
Message-ID: <20130321112021.GG1878@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <20130321104440.GA5053@brouette>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130321104440.GA5053@brouette>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Damien Wyart <damien.wyart@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>

On Thu, Mar 21, 2013 at 11:44:40AM +0100, Damien Wyart wrote:
> Hi,
> 
> > Kswapd and page reclaim behaviour has been screwy in one way or the
> > other for a long time. [...]
> 
> >  include/linux/mmzone.h |  16 ++
> >  mm/vmscan.c            | 387 +++++++++++++++++++++++++++++--------------------
> >  2 files changed, 245 insertions(+), 158 deletions(-)
>  
> Do you plan to respin the series with all the modifications coming from
> the various answers applied? I've not found a git repo hosting the
> series and I would prefer testing the most recent version.
> 

I plan to respin the series but as I'll be completely offline next week
so it'll happen some time after that. The actual functional changes so
far have been marginal so I was leaving more time for review instead of
spamming the list.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
