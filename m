Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1965A6B19D5
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 04:07:14 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id 80so68326227qkd.0
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 01:07:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j18si2074027qth.388.2018.11.19.01.07.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 01:07:13 -0800 (PST)
Date: Mon, 19 Nov 2018 17:06:46 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V10 17/19] block: don't use bio->bi_vcnt to figure out
 segment number
Message-ID: <20181119090645.GN16736@ming.t460p>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-18-ming.lei@redhat.com>
 <20181116021140.GL23828@vader>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116021140.GL23828@vader>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 06:11:40PM -0800, Omar Sandoval wrote:
> On Thu, Nov 15, 2018 at 04:53:04PM +0800, Ming Lei wrote:
> > It is wrong to use bio->bi_vcnt to figure out how many segments
> > there are in the bio even though CLONED flag isn't set on this bio,
> > because this bio may be splitted or advanced.
> > 
> > So always use bio_segments() in blk_recount_segments(), and it shouldn't
> > cause any performance loss now because the physical segment number is figured
> > out in blk_queue_split() and BIO_SEG_VALID is set meantime since
> > bdced438acd83ad83a6c ("block: setup bi_phys_segments after splitting").
> > 
> > Cc: Dave Chinner <dchinner@redhat.com>
> > Cc: Kent Overstreet <kent.overstreet@gmail.com>
> > Fixes: 7f60dcaaf91 ("block: blk-merge: fix blk_recount_segments()")
> 
> From what I can tell, the problem was originally introduced by
> 76d8137a3113 ("blk-merge: recaculate segment if it isn't less than max segments")
> 
> Is that right?

Indeed, will update it in next version.

Thanks,
Ming
