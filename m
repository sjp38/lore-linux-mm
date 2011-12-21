Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 165526B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 06:43:55 -0500 (EST)
Received: by iacb35 with SMTP id b35so13005240iac.14
        for <linux-mm@kvack.org>; Wed, 21 Dec 2011 03:43:54 -0800 (PST)
Date: Wed, 21 Dec 2011 20:43:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] cleanup: mm/migrate.c: cleanup comment for function
 migration_entry_wait
Message-ID: <20111221114337.GB12472@barrios-laptop.redhat.com>
References: <4EF1BE69.5090300@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EF1BE69.5090300@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 21, 2011 at 07:09:29PM +0800, Wang Sheng-Hui wrote:
> migration_entry_wait can also be called from hugetlb_fault now.
> Cleanup the comment.
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>

Alternative is to add hugetlbe_fault in comment but I think it's not useful
because We can find caller easily with cscope or just grep. 
My feeling is that the comment isn't helpful.
So I am okay to remove this comment.

Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
