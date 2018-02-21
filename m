Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB7816B0008
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 07:04:21 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j100so1258139wrj.4
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 04:04:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j21si5514966ede.121.2018.02.21.04.04.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Feb 2018 04:04:20 -0800 (PST)
Date: Wed, 21 Feb 2018 13:04:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: zsmalloc: Replace return type int with bool
Message-ID: <20180221120419.GE2231@dhcp22.suse.cz>
References: <20180220175811.GA28277@jordon-HP-15-Notebook-PC>
 <20180221102237.GB14384@dhcp22.suse.cz>
 <CAFqt6za=iGsXKa=2dfjOq=7fKy+BxAq_=08=OYPmAy8GwugXAA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6za=iGsXKa=2dfjOq=7fKy+BxAq_=08=OYPmAy8GwugXAA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, sergey.senozhatsky.work@gmail.com, Linux-MM <linux-mm@kvack.org>

On Wed 21-02-18 16:48:50, Souptick Joarder wrote:
> On Wed, Feb 21, 2018 at 3:52 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Tue 20-02-18 23:28:11, Souptick Joarder wrote:
> > [...]
> >> -static int zs_register_migration(struct zs_pool *pool)
> >> +static bool zs_register_migration(struct zs_pool *pool)
> >>  {
> >>       pool->inode = alloc_anon_inode(zsmalloc_mnt->mnt_sb);
> >>       if (IS_ERR(pool->inode)) {
> >>               pool->inode = NULL;
> >> -             return 1;
> >> +             return true;
> >>       }
> >>
> >>       pool->inode->i_mapping->private_data = pool;
> >>       pool->inode->i_mapping->a_ops = &zsmalloc_aops;
> >> -     return 0;
> >> +     return false;
> >>  }
> >
> > Don't you find it a bit strange that the function returns false on
> > success?
> 
> The original code was returning 0 on success  and return value was handled
> accordingly in zs_create_pool(). So returning false on success.

Returning 0 on success and an error code on failure is a standard
convention. Returning false is just weird. zs_register_migration is
somewhere in the middle because it doesn't really return an error code
on failure. Whether this is worth bothering and fixing is a question for
the maintainer but returning false on success is just not an improvement
IMHO.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
