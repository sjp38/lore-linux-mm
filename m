Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 5CAFA6B0005
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 10:39:38 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 02/10] mm: vmscan: Obey proportional scanning requirements for kswapd
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
	<1363525456-10448-3-git-send-email-mgorman@suse.de>
Date: Sun, 17 Mar 2013 07:39:37 -0700
In-Reply-To: <1363525456-10448-3-git-send-email-mgorman@suse.de> (Mel Gorman's
	message of "Sun, 17 Mar 2013 13:04:08 +0000")
Message-ID: <m2a9q2jdjq.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

Mel Gorman <mgorman@suse.de> writes:
> +
> +	/*
> +	 * For direct reclaim, reclaim the number of pages requested. Less
> +	 * care is taken to ensure that scanning for each LRU is properly
> +	 * proportional. This is unfortunate and is improper aging but
> +	 * minimises the amount of time a process is stalled.
> +	 */
> +	if (!current_is_kswapd()) {
> +		if (nr_reclaimed >= nr_to_reclaim) {
> +			for_each_evictable_lru(l)

Don't we need some NUMA awareness here?
Similar below.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
