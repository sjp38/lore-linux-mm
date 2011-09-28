Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 92C459000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 02:04:53 -0400 (EDT)
Received: by iaen33 with SMTP id n33so10611490iae.14
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 23:04:51 -0700 (PDT)
Date: Wed, 28 Sep 2011 15:04:43 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm: compaction: staticize compact_zone_order
Message-ID: <20110928060443.GE14561@barrios-desktop>
References: <20110921085843.GA16233@july>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110921085843.GA16233@july>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kmpark@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 21, 2011 at 05:58:43PM +0900, Kyungmin Park wrote:
> From: Kyungmin Park <kyungmin.park@samsung.com>
> 
> There's no user to use compact_zone_order. So staticize this function.
> 
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
