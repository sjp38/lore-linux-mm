Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4B86B3F64
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 07:55:51 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id h11so16361010wrs.2
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 04:55:51 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id f18si544697wmc.85.2018.11.26.04.55.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 04:55:50 -0800 (PST)
Date: Mon, 26 Nov 2018 13:55:49 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V12 08/20] block: introduce bio_for_each_bvec() and
 rq_for_each_bvec()
Message-ID: <20181126125549.GD6383@lst.de>
References: <20181126021720.19471-1-ming.lei@redhat.com> <20181126021720.19471-9-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126021720.19471-9-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Mon, Nov 26, 2018 at 10:17:08AM +0800, Ming Lei wrote:
> bio_for_each_bvec() is used for iterating over multi-page bvec for bio
> split & merge code.
> 
> rq_for_each_bvec() can be used for drivers which may handle the
> multi-page bvec directly, so far loop is one perfect use case.
> 
> Reviewed-by: Omar Sandoval <osandov@fb.com>
> Signed-off-by: Ming Lei <ming.lei@redhat.com>

Looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>
