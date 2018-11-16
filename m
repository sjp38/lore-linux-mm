Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id BDF736B099D
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 08:13:07 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id y85so13023208wmc.7
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 05:13:07 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r75-v6si18307254wmb.60.2018.11.16.05.13.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 05:13:06 -0800 (PST)
Date: Fri, 16 Nov 2018 14:13:05 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V10 01/19] block: introduce multi-page page bvec helpers
Message-ID: <20181116131305.GA3165@lst.de>
References: <20181115085306.9910-1-ming.lei@redhat.com> <20181115085306.9910-2-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-2-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

> -#define bvec_iter_page(bvec, iter)				\
> +#define mp_bvec_iter_page(bvec, iter)				\
>  	(__bvec_iter_bvec((bvec), (iter))->bv_page)
>  
> -#define bvec_iter_len(bvec, iter)				\
> +#define mp_bvec_iter_len(bvec, iter)				\

I'd much prefer if we would stick to the segment naming that
we also use in the higher level helper.

So segment_iter_page, segment_iter_len, etc.

> + * This helpers are for building sp bvec in flight.

Please spell out single page, sp is not easy understandable.
