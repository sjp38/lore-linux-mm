Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 323E06B0A6A
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 11:40:55 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id l15-v6so19540525pff.5
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 08:40:55 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v19-v6sor37388697plo.32.2018.11.16.08.40.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Nov 2018 08:40:54 -0800 (PST)
Date: Fri, 16 Nov 2018 08:40:51 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V10 19/19] block: kill BLK_MQ_F_SG_MERGE
Message-ID: <20181116164051.GX23828@vader>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-20-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-20-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:53:06PM +0800, Ming Lei wrote:
> QUEUE_FLAG_NO_SG_MERGE has been killed, so kill BLK_MQ_F_SG_MERGE too.
> 
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Kent Overstreet <kent.overstreet@gmail.com>
> Cc: Mike Snitzer <snitzer@redhat.com>
> Cc: dm-devel@redhat.com
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: linux-fsdevel@vger.kernel.org
> Cc: Shaohua Li <shli@kernel.org>
> Cc: linux-raid@vger.kernel.org
> Cc: linux-erofs@lists.ozlabs.org
> Cc: David Sterba <dsterba@suse.com>
> Cc: linux-btrfs@vger.kernel.org
> Cc: Darrick J. Wong <darrick.wong@oracle.com>
> Cc: linux-xfs@vger.kernel.org
> Cc: Gao Xiang <gaoxiang25@huawei.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Theodore Ts'o <tytso@mit.edu>
> Cc: linux-ext4@vger.kernel.org
> Cc: Coly Li <colyli@suse.de>
> Cc: linux-bcache@vger.kernel.org
> Cc: Boaz Harrosh <ooo@electrozaur.com>
> Cc: Bob Peterson <rpeterso@redhat.com>
> Cc: cluster-devel@redhat.com

Reviewed-by: Omar Sandoval <osandov@fb.com>

> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  block/blk-mq-debugfs.c       | 1 -
>  drivers/block/loop.c         | 2 +-
>  drivers/block/nbd.c          | 2 +-
>  drivers/block/rbd.c          | 2 +-
>  drivers/block/skd_main.c     | 1 -
>  drivers/block/xen-blkfront.c | 2 +-
>  drivers/md/dm-rq.c           | 2 +-
>  drivers/mmc/core/queue.c     | 3 +--
>  drivers/scsi/scsi_lib.c      | 2 +-
>  include/linux/blk-mq.h       | 1 -
>  10 files changed, 7 insertions(+), 11 deletions(-)

[snip]
