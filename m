Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 888406B262D
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 10:07:23 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id n95so3561959qte.16
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 07:07:23 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v11si2339389qvj.128.2018.11.21.07.07.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 07:07:22 -0800 (PST)
Date: Wed, 21 Nov 2018 23:06:11 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V11 02/19] block: introduce multi-page bvec helpers
Message-ID: <20181121150610.GA19111@ming.t460p>
References: <20181121032327.8434-1-ming.lei@redhat.com>
 <20181121032327.8434-3-ming.lei@redhat.com>
 <20181121131928.GA1640@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121131928.GA1640@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Wed, Nov 21, 2018 at 02:19:28PM +0100, Christoph Hellwig wrote:
> On Wed, Nov 21, 2018 at 11:23:10AM +0800, Ming Lei wrote:
> > This patch introduces helpers of 'segment_iter_*' for multipage
> > bvec support.
> > 
> > The introduced helpers treate one bvec as real multi-page segment,
> > which may include more than one pages.
> 
> Unless I'm missing something these bvec vs segment names are exactly
> inverted vs how we use it elsewhere.
> 
> In the iterators we use segment for single-page bvec, and bvec for multi
> page ones, and here it is inverse.  Please switch it around.

bvec_iter_* is used for single-page bvec in current linus tree, and there are
lots of users now:

[linux]$ git grep -n "bvec_iter_*" ./ | wc
    191     995   13242

If we have to switch it first, it can be a big change, just wondering if Jens
is happy with that?

Thanks,
Ming
