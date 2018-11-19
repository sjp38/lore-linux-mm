Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A83566B1997
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 03:29:55 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id f22so66767468qkm.11
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 00:29:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e97si1196858qtb.180.2018.11.19.00.29.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 00:29:54 -0800 (PST)
Date: Mon, 19 Nov 2018 16:29:32 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V10 12/19] block: allow bio_for_each_segment_all() to
 iterate over multi-page bvec
Message-ID: <20181119082931.GG16736@ming.t460p>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-13-ming.lei@redhat.com>
 <20181115124252.GP24115@twin.jikos.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115124252.GP24115@twin.jikos.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dsterba@suse.cz, Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 01:42:52PM +0100, David Sterba wrote:
> On Thu, Nov 15, 2018 at 04:52:59PM +0800, Ming Lei wrote:
> > diff --git a/block/blk-zoned.c b/block/blk-zoned.c
> > index 13ba2011a306..789b09ae402a 100644
> > --- a/block/blk-zoned.c
> > +++ b/block/blk-zoned.c
> > @@ -123,6 +123,7 @@ static int blk_report_zones(struct gendisk *disk, sector_t sector,
> >  	unsigned int z = 0, n, nrz = *nr_zones;
> >  	sector_t capacity = get_capacity(disk);
> >  	int ret;
> > +	struct bvec_iter_all iter_all;
> >  
> >  	while (z < nrz && sector < capacity) {
> >  		n = nrz - z;
> 
> iter_all is added but not used and I don't see any
> bio_for_each_segment_all for conversion in this function.

Good catch, will fix it in next version.

Thanks,
Ming
