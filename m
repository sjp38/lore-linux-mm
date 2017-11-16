Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3ECD0280259
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 08:18:07 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id j16so23921129pgn.14
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 05:18:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m3si888662pld.27.2017.11.16.05.18.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 05:18:06 -0800 (PST)
Date: Thu, 16 Nov 2017 14:18:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: shmem: remove unused info variable
Message-ID: <20171116131804.o43atl6lizirmx5p@dhcp22.suse.cz>
References: <1510774029-30652-1-git-send-email-clabbe@baylibre.com>
 <20171116131743.xwgljzw62eyzqwiw@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171116131743.xwgljzw62eyzqwiw@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Corentin Labbe <clabbe@baylibre.com>
Cc: hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Thu 16-11-17 14:17:43, Michal Hocko wrote:
> This seems familiar. Ohh, you have posted it
> http://lkml.kernel.org/r/20171021165032.20542-1-clabbe.montjoie@gmail.com
> already. It fall though cracks, it seems. CCing Andrew 

now, for real

> On Wed 15-11-17 19:27:09, Corentin Labbe wrote:
> > This patch fix the following build warning by simply removing the unused
> > info variable.
> > mm/shmem.c:3205:27: warning: variable 'info' set but not used [-Wunused-but-set-variable]
> > 
> > Signed-off-by: Corentin Labbe <clabbe@baylibre.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> > ---
> >  mm/shmem.c | 2 --
> >  1 file changed, 2 deletions(-)
> > 
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index 544c105d706a..7fbe67be86fa 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -3202,7 +3202,6 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
> >  	int len;
> >  	struct inode *inode;
> >  	struct page *page;
> > -	struct shmem_inode_info *info;
> >  
> >  	len = strlen(symname) + 1;
> >  	if (len > PAGE_SIZE)
> > @@ -3222,7 +3221,6 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
> >  		error = 0;
> >  	}
> >  
> > -	info = SHMEM_I(inode);
> >  	inode->i_size = len-1;
> >  	if (len <= SHORT_SYMLINK_LEN) {
> >  		inode->i_link = kmemdup(symname, len, GFP_KERNEL);
> > -- 
> > 2.13.6
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
