Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 11A796B016A
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 05:28:17 -0400 (EDT)
Received: by pzk33 with SMTP id 33so6331845pzk.36
        for <linux-mm@kvack.org>; Fri, 29 Jul 2011 02:28:15 -0700 (PDT)
Date: Fri, 29 Jul 2011 18:28:07 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch 2/3]vmscan: count pages into balanced for zone with good
 watermark
Message-ID: <20110729092807.GE1843@barrios-desktop>
References: <1311840785.15392.408.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1311840785.15392.408.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, mgorman@suse.de

On Thu, Jul 28, 2011 at 04:13:05PM +0800, Shaohua Li wrote:
> It's possible a zone watermark is ok at entering balance_pgdat loop, while the
> zone is within requested classzone_idx. Countering pages from the zone into
> balanced. In this way, we can skip shrinking zones too much for high
> order allocation.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Nice catch, Shaohua!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
