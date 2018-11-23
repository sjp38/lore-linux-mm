Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1286B2E9A
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 21:20:02 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id d35so7682121qtd.20
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 18:20:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e2si7635462qto.135.2018.11.22.18.20.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 18:20:01 -0800 (PST)
Date: Fri, 23 Nov 2018 10:19:34 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V11 12/19] block: allow bio_for_each_segment_all() to
 iterate over multi-page bvec
Message-ID: <20181123021933.GB20110@ming.t460p>
References: <20181121032327.8434-1-ming.lei@redhat.com>
 <20181121032327.8434-13-ming.lei@redhat.com>
 <20181122110315.GA30369@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122110315.GA30369@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 22, 2018 at 12:03:15PM +0100, Christoph Hellwig wrote:
> > +/* used for chunk_for_each_segment */
> > +static inline void bvec_next_segment(const struct bio_vec *bvec,
> > +				     struct bvec_iter_all *iter_all)
> 
> FYI, chunk_for_each_segment doesn't exist anymore, this is
> bvec_for_each_segment now.  Not sure the comment helps much, though.

OK, will remove the comment.

> 
> > +{
> > +	struct bio_vec *bv = &iter_all->bv;
> > +
> > +	if (bv->bv_page) {
> > +		bv->bv_page += 1;
> 
> I think this needs to use nth_page() given that with discontigmem
> page structures might not be allocated contigously.

Good catch!

Thanks,
Ming
