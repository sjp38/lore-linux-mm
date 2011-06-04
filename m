Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8E03B6B0092
	for <linux-mm@kvack.org>; Sat,  4 Jun 2011 03:25:22 -0400 (EDT)
Received: by pzk4 with SMTP id 4so1383535pzk.14
        for <linux-mm@kvack.org>; Sat, 04 Jun 2011 00:25:21 -0700 (PDT)
Date: Sat, 4 Jun 2011 16:25:12 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110604072512.GB4114@barrios-laptop>
References: <20110601191529.GY19505@random.random>
 <20110601214018.GC7306@suse.de>
 <20110601233036.GZ19505@random.random>
 <20110602010352.GD7306@suse.de>
 <20110602132954.GC19505@random.random>
 <20110602145019.GG7306@suse.de>
 <20110602153754.GF19505@random.random>
 <20110603020920.GA26753@suse.de>
 <20110603144941.GI7306@suse.de>
 <20110603154554.GK2802@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110603154554.GK2802@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Fri, Jun 03, 2011 at 05:45:54PM +0200, Andrea Arcangeli wrote:
> On Fri, Jun 03, 2011 at 03:49:41PM +0100, Mel Gorman wrote:
> > Right idea of the wrong zone being accounted for but wrong place. I
> > think the following patch should fix the problem;
> 
> Looks good thanks.
> 
> I also found this bug during my debugging that made NR_SHMEM underflow.
> 
> ===
> Subject: migrate: don't account swapcache as shmem
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> swapcache will reach the below code path in migrate_page_move_mapping,
> and swapcache is accounted as NR_FILE_PAGES but it's not accounted as
> NR_SHMEM.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Nice catch!
-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
