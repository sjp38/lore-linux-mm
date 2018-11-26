Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 270116B3F84
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 08:11:22 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id 127so16000957wmm.6
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 05:11:22 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id n6si223800wrw.334.2018.11.26.05.11.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 05:11:20 -0800 (PST)
Date: Mon, 26 Nov 2018 14:11:20 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V12 09/20] block: use bio_for_each_bvec() to compute
 multi-page bvec count
Message-ID: <20181126131120.GA6757@lst.de>
References: <20181126021720.19471-1-ming.lei@redhat.com> <20181126021720.19471-10-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126021720.19471-10-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

Looks fine:

Reviewed-by: Christoph Hellwig <hch@lst.de>

Nitpick below:

> +{
> +	unsigned len = bv->bv_len;
> +	unsigned total_len = 0;
> +	unsigned new_nsegs = 0, seg_size = 0;
> +
> +	/*
> +	 * Multipage bvec may be too big to hold in one segment,
> +	 * so the current bvec has to be splitted as multiple
> +	 * segments.
> +	 */

Please use up all 80 chars in a line.
