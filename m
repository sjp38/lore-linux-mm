Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 615216B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 06:59:20 -0400 (EDT)
Date: Thu, 28 Jul 2011 11:59:14 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 2/3]vmscan: count pages into balanced for zone with good
 watermark
Message-ID: <20110728105914.GK3010@suse.de>
References: <1311840785.15392.408.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1311840785.15392.408.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Jul 28, 2011 at 04:13:05PM +0800, Shaohua Li wrote:
> It's possible a zone watermark is ok at entering balance_pgdat loop, while the
> zone is within requested classzone_idx. Countering pages from the zone into
> balanced. In this way, we can skip shrinking zones too much for high
> order allocation.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
