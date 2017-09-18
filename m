Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DABFF6B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 03:53:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y29so14333129pff.6
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 00:53:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 136si4206597pgf.326.2017.09.18.00.53.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Sep 2017 00:53:47 -0700 (PDT)
Date: Mon, 18 Sep 2017 09:53:43 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 13/15] ceph: Use pagevec_lookup_range_nr_tag()
Message-ID: <20170918075343.GB32516@quack2.suse.cz>
References: <20170914131819.26266-1-jack@suse.cz>
 <20170914131819.26266-14-jack@suse.cz>
 <CAAM7YAnHjkGRhzeUUXOMnux70UKqnQ3kG6x0jRpzasSNeyAVCg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAM7YAnHjkGRhzeUUXOMnux70UKqnQ3kG6x0jRpzasSNeyAVCg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Yan, Zheng" <ukernel@gmail.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, "Linux F2FS DEV, Mailing List" <linux-f2fs-devel@lists.sourceforge.net>, Jaegeuk Kim <jaegeuk@kernel.org>, ceph-devel <ceph-devel@vger.kernel.org>, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>

On Mon 18-09-17 13:35:50, Yan, Zheng wrote:
> On Thu, Sep 14, 2017 at 9:18 PM, Jan Kara <jack@suse.cz> wrote:
> > Use new function for looking up pages since nr_pages argument from
> > pagevec_lookup_range_tag() is going away.
> >
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  fs/ceph/addr.c | 6 ++----
> >  1 file changed, 2 insertions(+), 4 deletions(-)
> >
> > diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
> > index e57e9d37bf2d..87789c477381 100644
> > --- a/fs/ceph/addr.c
> > +++ b/fs/ceph/addr.c
> > @@ -869,11 +869,9 @@ static int ceph_writepages_start(struct address_space *mapping,
> >                 max_pages = wsize >> PAGE_SHIFT;
> >
> >  get_more_pages:
> > -               pvec_pages = min_t(unsigned, PAGEVEC_SIZE,
> > -                                  max_pages - locked_pages);
> > -               pvec_pages = pagevec_lookup_range_tag(&pvec, mapping, &index,
> > +               pvec_pages = pagevec_lookup_range_nr_tag(&pvec, mapping, &index,
> >                                                 end, PAGECACHE_TAG_DIRTY,
> > -                                               pvec_pages);
> > +                                               max_pages - locked_pages);
> >                 dout("pagevec_lookup_range_tag got %d\n", pvec_pages);
> >                 if (!pvec_pages && !locked_pages)
> >                         break;
> > --
> > 2.12.3
> >
> 
> Reviewed-by: "Yan, Zheng" <zyan@redhat.com>

Thanks for the review!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
