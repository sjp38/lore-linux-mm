Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 00AAA6B24DA
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 09:00:30 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id d126so7766108wme.2
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 06:00:29 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id u185si904941wme.67.2018.11.21.06.00.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 06:00:28 -0800 (PST)
Date: Wed, 21 Nov 2018 15:00:27 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V11 10/19] block: loop: pass multi-page bvec to iov_iter
Message-ID: <20181121140027.GA2323@lst.de>
References: <20181121032327.8434-1-ming.lei@redhat.com> <20181121032327.8434-11-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121032327.8434-11-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

> diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
> index 1ad6eafc43f2..a281b6737b61 100644
> --- a/include/linux/blkdev.h
> +++ b/include/linux/blkdev.h
> @@ -805,6 +805,10 @@ struct req_iterator {
>  	__rq_for_each_bio(_iter.bio, _rq)			\
>  		bio_for_each_segment(bvl, _iter.bio, _iter.iter)
>  
> +#define rq_for_each_bvec(bvl, _rq, _iter)			\
> +	__rq_for_each_bio(_iter.bio, _rq)			\
> +		bio_for_each_bvec(bvl, _iter.bio, _iter.iter)
> +

I think this should go into the patch adding bio_for_each_bvec and
friends.

Otherwise looks fine:

Reviewed-by: Christoph Hellwig <hch@lst.de>
