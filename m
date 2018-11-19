Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C103C6B199E
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 03:28:47 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id s19so68234627qke.20
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 00:28:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s17si2201956qki.14.2018.11.19.00.28.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 00:28:47 -0800 (PST)
Date: Mon, 19 Nov 2018 16:28:20 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V10 11/19] bcache: avoid to use
 bio_for_each_segment_all() in bch_bio_alloc_pages()
Message-ID: <20181119082818.GF16736@ming.t460p>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-12-ming.lei@redhat.com>
 <20181116134645.GI3165@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116134645.GI3165@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Fri, Nov 16, 2018 at 02:46:45PM +0100, Christoph Hellwig wrote:
> > -	bio_for_each_segment_all(bv, bio, i) {
> > +	for (i = 0, bv = bio->bi_io_vec; i < bio->bi_vcnt; bv++) {
> 
> This really needs a comment.  Otherwise it looks fine to me.

OK, will do it in next version.

Thanks,
Ming
