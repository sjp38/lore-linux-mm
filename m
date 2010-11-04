Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3FFE26B00BB
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 10:00:16 -0400 (EDT)
Date: Thu, 4 Nov 2010 15:00:11 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch]vmscan: avoid set zone congested if no page dirty
Message-ID: <20101104140011.GC6384@cmpxchg.org>
References: <1288831858.23014.129.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1288831858.23014.129.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, mel <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 04, 2010 at 08:50:58AM +0800, Shaohua Li wrote:
> nr_dirty and nr_congested are increased only when page is dirty. So if all pages
> are clean, both them will be zero. In this case, we should not mark the zone
> congested.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
