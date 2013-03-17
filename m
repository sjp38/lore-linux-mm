Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 114BB6B0005
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 11:08:11 -0400 (EDT)
Date: Sun, 17 Mar 2013 15:08:07 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/10] mm: vmscan: Obey proportional scanning
 requirements for kswapd
Message-ID: <20130317150807.GA2026@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-3-git-send-email-mgorman@suse.de>
 <m2a9q2jdjq.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <m2a9q2jdjq.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Sun, Mar 17, 2013 at 07:39:37AM -0700, Andi Kleen wrote:
> Mel Gorman <mgorman@suse.de> writes:
> > +
> > +	/*
> > +	 * For direct reclaim, reclaim the number of pages requested. Less
> > +	 * care is taken to ensure that scanning for each LRU is properly
> > +	 * proportional. This is unfortunate and is improper aging but
> > +	 * minimises the amount of time a process is stalled.
> > +	 */
> > +	if (!current_is_kswapd()) {
> > +		if (nr_reclaimed >= nr_to_reclaim) {
> > +			for_each_evictable_lru(l)
> 
> Don't we need some NUMA awareness here?
> Similar below.
> 

Of what sort? In this context we are usually dealing with a zone and in
the case of kswapd it is only ever dealing with a single node.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
