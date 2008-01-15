Date: Tue, 15 Jan 2008 18:04:55 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] Updating ctime and mtime at syncing
Message-ID: <20080115180455.GB21557@infradead.org>
References: <12004129652397-git-send-email-salikhmetov@gmail.com> <1200412978699-git-send-email-salikhmetov@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1200412978699-git-send-email-salikhmetov@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Salikhmetov <salikhmetov@gmail.com>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu
List-ID: <linux-mm.kvack.org>

On Tue, Jan 15, 2008 at 07:02:45PM +0300, Anton Salikhmetov wrote:
> +/*
> + * Update the ctime and mtime stamps for memory-mapped block device files.
> + */
> +static void bd_inode_update_time(struct inode *inode, struct timespec *ts)
> +{
> +	struct block_device *bdev = inode->i_bdev;
> +	struct list_head *p;
> +
> +	if (bdev == NULL)
> +		return;

inode->i_bdev is never NULL for inodes currently beeing written to.

> +
> +	mutex_lock(&bdev->bd_mutex);
> +	list_for_each(p, &bdev->bd_inodes) {
> +		inode = list_entry(p, struct inode, i_devices);

this should use list_for_each_entry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
