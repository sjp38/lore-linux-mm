Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E00E86B02E7
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 07:43:14 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e17so6542850edr.7
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 04:43:14 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i1-v6si5205221edi.328.2018.11.15.04.43.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 04:43:13 -0800 (PST)
Date: Thu, 15 Nov 2018 13:42:52 +0100
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH V10 12/19] block: allow bio_for_each_segment_all() to
 iterate over multi-page bvec
Message-ID: <20181115124252.GP24115@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-13-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-13-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:52:59PM +0800, Ming Lei wrote:
> diff --git a/block/blk-zoned.c b/block/blk-zoned.c
> index 13ba2011a306..789b09ae402a 100644
> --- a/block/blk-zoned.c
> +++ b/block/blk-zoned.c
> @@ -123,6 +123,7 @@ static int blk_report_zones(struct gendisk *disk, sector_t sector,
>  	unsigned int z = 0, n, nrz = *nr_zones;
>  	sector_t capacity = get_capacity(disk);
>  	int ret;
> +	struct bvec_iter_all iter_all;
>  
>  	while (z < nrz && sector < capacity) {
>  		n = nrz - z;

iter_all is added but not used and I don't see any
bio_for_each_segment_all for conversion in this function.
