Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id C79E76B0005
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 06:44:41 -0400 (EDT)
Date: Thu, 21 Mar 2013 11:44:40 +0100
From: Damien Wyart <damien.wyart@gmail.com>
Subject: Re: [RFC PATCH 0/8] Reduce system disruption due to kswapd
Message-ID: <20130321104440.GA5053@brouette>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363525456-10448-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>

Hi,

> Kswapd and page reclaim behaviour has been screwy in one way or the
> other for a long time. [...]

>  include/linux/mmzone.h |  16 ++
>  mm/vmscan.c            | 387 +++++++++++++++++++++++++++++--------------------
>  2 files changed, 245 insertions(+), 158 deletions(-)
 
Do you plan to respin the series with all the modifications coming from
the various answers applied? I've not found a git repo hosting the
series and I would prefer testing the most recent version.


Many thanks in advance,
-- 
Damien Wyart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
