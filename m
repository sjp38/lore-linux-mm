Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 5A5BD6B004D
	for <linux-mm@kvack.org>; Fri, 30 Dec 2011 10:16:01 -0500 (EST)
Date: Fri, 30 Dec 2011 15:15:56 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm/migrate.c: remove the unused macro lru_to_page
Message-ID: <20111230151556.GF15729@suse.de>
References: <4EFA87E4.8040609@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4EFA87E4.8040609@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 28, 2011 at 11:07:16AM +0800, Wang Sheng-Hui wrote:
> lru_to_page is not used in mm/migrate.c. Drop it.
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>

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
