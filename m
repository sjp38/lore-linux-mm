Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 108226B09B8
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 08:55:14 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id g17-v6so26477649wrw.6
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 05:55:14 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id u14-v6si24364365wrq.254.2018.11.16.05.55.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 05:55:12 -0800 (PST)
Date: Fri, 16 Nov 2018 14:55:12 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V10 17/19] block: don't use bio->bi_vcnt to figure out
 segment number
Message-ID: <20181116135512.GM3165@lst.de>
References: <20181115085306.9910-1-ming.lei@redhat.com> <20181115085306.9910-18-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-18-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:53:04PM +0800, Ming Lei wrote:
> It is wrong to use bio->bi_vcnt to figure out how many segments
> there are in the bio even though CLONED flag isn't set on this bio,
> because this bio may be splitted or advanced.
> 
> So always use bio_segments() in blk_recount_segments(), and it shouldn't
> cause any performance loss now because the physical segment number is figured
> out in blk_queue_split() and BIO_SEG_VALID is set meantime since
> bdced438acd83ad83a6c ("block: setup bi_phys_segments after splitting").

Looks good, but shouldn't this go to the beginning of the series?

Reviewed-by: Christoph Hellwig <hch@lst.de>
