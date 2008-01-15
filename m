Received: by hs-out-2122.google.com with SMTP id 23so2511763hsn.6
        for <linux-mm@kvack.org>; Tue, 15 Jan 2008 11:04:40 -0800 (PST)
Message-ID: <4df4ef0c0801151104j5b2d003ep72600fd7553f5832@mail.gmail.com>
Date: Tue, 15 Jan 2008 22:04:38 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH 2/2] Updating ctime and mtime at syncing
In-Reply-To: <20080115180455.GB21557@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12004129652397-git-send-email-salikhmetov@gmail.com>
	 <1200412978699-git-send-email-salikhmetov@gmail.com>
	 <20080115180455.GB21557@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu
List-ID: <linux-mm.kvack.org>

2008/1/15, Christoph Hellwig <hch@infradead.org>:
> On Tue, Jan 15, 2008 at 07:02:45PM +0300, Anton Salikhmetov wrote:
> > +/*
> > + * Update the ctime and mtime stamps for memory-mapped block device files.
> > + */
> > +static void bd_inode_update_time(struct inode *inode, struct timespec *ts)
> > +{
> > +     struct block_device *bdev = inode->i_bdev;
> > +     struct list_head *p;
> > +
> > +     if (bdev == NULL)
> > +             return;
>
> inode->i_bdev is never NULL for inodes currently beeing written to.
>
> > +
> > +     mutex_lock(&bdev->bd_mutex);
> > +     list_for_each(p, &bdev->bd_inodes) {
> > +             inode = list_entry(p, struct inode, i_devices);
>
> this should use list_for_each_entry.
>
>

Thank you very much for your recommenations. I'll take them into account.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
