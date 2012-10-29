Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id A94566B006C
	for <linux-mm@kvack.org>; Sun, 28 Oct 2012 21:42:21 -0400 (EDT)
Date: Mon, 29 Oct 2012 10:48:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/5] mm, highmem: use PKMAP_NR() to calculate an index of
 pkmap
Message-ID: <20121029014805.GF15767@bbox>
References: <Yes>
 <1351451576-2611-1-git-send-email-js1304@gmail.com>
 <1351451576-2611-2-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351451576-2611-2-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>

On Mon, Oct 29, 2012 at 04:12:52AM +0900, Joonsoo Kim wrote:
> To calculate an index of pkmap, using PKMAP_NR() is more understandable
> and maintainable, So change it.
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
