Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id BD32F6B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 06:35:17 -0400 (EDT)
Date: Tue, 19 Mar 2013 10:35:12 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 06/10] mm: vmscan: Have kswapd writeback pages based on
 dirty pages encountered, not priority
Message-ID: <20130319103512.GG2055@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-7-git-send-email-mgorman@suse.de>
 <20130318110850.GA7144@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130318110850.GA7144@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Mon, Mar 18, 2013 at 07:08:50PM +0800, Wanpeng Li wrote:
> >@@ -2735,8 +2748,12 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> > 				end_zone = i;
> > 				break;
> > 			} else {
> >-				/* If balanced, clear the congested flag */
> >+				/*
> >+				 * If balanced, clear the dirty and congested
> >+				 * flags
> >+				 */
> > 				zone_clear_flag(zone, ZONE_CONGESTED);
> >+				zone_clear_flag(zone, ZONE_DIRTY);
> 
> Hi Mel,
> 
> There are two places in balance_pgdat clear ZONE_CONGESTED flag, one
> is during scan zone which have free_pages <= high_wmark_pages(zone), the 
> other one is zone get balanced after reclaim, it seems that you miss the 
> later one.
> 

I did and it's fixed now. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
