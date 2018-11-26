Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA1D6B4400
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 17:18:42 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id p9so12456969pfj.3
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 14:18:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y17sor2315749pll.68.2018.11.26.14.18.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 14:18:41 -0800 (PST)
Date: Mon, 26 Nov 2018 14:18:35 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V12 06/20] block: rename bvec helpers
Message-ID: <20181126221835.GG30411@vader>
References: <20181126021720.19471-1-ming.lei@redhat.com>
 <20181126021720.19471-7-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126021720.19471-7-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Mon, Nov 26, 2018 at 10:17:06AM +0800, Ming Lei wrote:
> We will support multi-page bvec soon, and have to deal with
> single-page vs multi-page bvec. This patch follows Christoph's
> suggestion to rename all the following helpers:
> 
> 	for_each_bvec
> 	bvec_iter_bvec
> 	bvec_iter_len
> 	bvec_iter_page
> 	bvec_iter_offset
> 
> into:
> 	for_each_segment
> 	segment_iter_bvec
> 	segment_iter_len
> 	segment_iter_page
> 	segment_iter_offset
> 
> so that these helpers named with 'segment' only deal with single-page
> bvec, or called segment. We will introduce helpers named with 'bvec'
> for multi-page bvec.
> 
> bvec_iter_advance() isn't renamed becasue this helper is always operated
> on real bvec even though multi-page bvec is supported.
> 
> Suggested-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Omar Sandoval <osandov@fb.com>

> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  .clang-format                  |  2 +-
>  drivers/md/dm-integrity.c      |  2 +-
>  drivers/md/dm-io.c             |  4 ++--
>  drivers/nvdimm/blk.c           |  4 ++--
>  drivers/nvdimm/btt.c           |  4 ++--
>  include/linux/bio.h            | 10 +++++-----
>  include/linux/bvec.h           | 20 +++++++++++---------
>  include/linux/ceph/messenger.h |  2 +-
>  lib/iov_iter.c                 |  2 +-
>  net/ceph/messenger.c           | 14 +++++++-------
>  10 files changed, 33 insertions(+), 31 deletions(-)
