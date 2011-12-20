Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 079396B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 02:18:19 -0500 (EST)
Received: by qadc16 with SMTP id c16so4411655qad.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 23:18:19 -0800 (PST)
Date: Tue, 20 Dec 2011 16:18:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 08/11] mm: compaction: Introduce sync-light migration for
 use by compaction
Message-ID: <20111220071804.GB19025@barrios-laptop.redhat.com>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
 <1323877293-15401-9-git-send-email-mgorman@suse.de>
 <20111218020552.GB13069@barrios-laptop.redhat.com>
 <20111219114522.GK3487@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111219114522.GK3487@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Dec 19, 2011 at 11:45:22AM +0000, Mel Gorman wrote:
> On Sun, Dec 18, 2011 at 11:05:52AM +0900, Minchan Kim wrote:
> > On Wed, Dec 14, 2011 at 03:41:30PM +0000, Mel Gorman wrote:
> > > This patch adds a lightweight sync migrate operation MIGRATE_SYNC_LIGHT
> > > mode that avoids writing back pages to backing storage. Async
> > > compaction maps to MIGRATE_ASYNC while sync compaction maps to
> > > MIGRATE_SYNC_LIGHT. For other migrate_pages users such as memory
> > > hotplug, MIGRATE_SYNC is used.
> > > 
> > > This avoids sync compaction stalling for an excessive length of time,
> > > particularly when copying files to a USB stick where there might be
> > > a large number of dirty pages backed by a filesystem that does not
> > > support ->writepages.
> > > 
> > > [aarcange@redhat.com: This patch is heavily based on Andrea's work]
> > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > 
> > Acked-by: Minchan Kim <minchan@kernel.org>
> > 
> 
> Thanks.
> 
> > > <SNIP>
> > > diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> > > index 10b9883..6b80537 100644
> > > --- a/fs/hugetlbfs/inode.c
> > > +++ b/fs/hugetlbfs/inode.c
> > > @@ -577,7 +577,7 @@ static int hugetlbfs_set_page_dirty(struct page *page)
> > >  
> > >  static int hugetlbfs_migrate_page(struct address_space *mapping,
> > >  				struct page *newpage, struct page *page,
> > > -				bool sync)
> > > +				enum migrate_mode mode)
> > 
> > Nitpick, except this one, we use enum migrate_mode sync.
> > 
> 
> Actually, in all the core code, I used "mode" but I was inconsistent in
> the headers and some of the filesystems. I should have converted all use
> of "sync" which was a boolean to a mode which has three possible values
> after this patch.
> 
> ==== CUT HERE ====
> mm: compaction: Introduce sync-light migration for use by compaction fix
> 
> Consistently name enum migrate_mode parameters "mode" instead of "sync".
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
