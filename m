Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 176B46B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 05:55:20 -0400 (EDT)
Date: Tue, 19 Mar 2013 09:55:15 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 01/10] mm: vmscan: Limit the number of pages kswapd
 reclaims at each priority
Message-ID: <20130319095514.GA2055@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-2-git-send-email-mgorman@suse.de>
 <5147A8EC.5010908@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5147A8EC.5010908@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Mar 19, 2013 at 07:53:16AM +0800, Simon Jeons wrote:
> Hi Mel,
> On 03/17/2013 09:04 PM, Mel Gorman wrote:
> >The number of pages kswapd can reclaim is bound by the number of pages it
> >scans which is related to the size of the zone and the scanning priority. In
> >many cases the priority remains low because it's reset every SWAP_CLUSTER_MAX
> >reclaimed pages but in the event kswapd scans a large number of pages it
> >cannot reclaim, it will raise the priority and potentially discard a large
> >percentage of the zone as sc->nr_to_reclaim is ULONG_MAX. The user-visible
> >effect is a reclaim "spike" where a large percentage of memory is suddenly
> >freed. It would be bad enough if this was just unused memory but because
> 
> Since there is nr_reclaimed >= nr_to_reclaim check if priority is
> large than DEF_PRIORITY in shrink_lruvec, how can a large percentage
> of memory is suddenly freed happen?
> 

Because of the priority checks made in get_scan_count(). Patch 5 has
more detail on why this happens.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
