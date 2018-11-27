Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 20DD86B4531
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 21:25:48 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id 42so18459979qtr.7
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 18:25:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n83si1869909qkl.183.2018.11.26.18.25.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 18:25:47 -0800 (PST)
Date: Tue, 27 Nov 2018 10:25:19 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V12 16/20] block: enable multipage bvecs
Message-ID: <20181127022517.GC25199@ming.t460p>
References: <20181126021720.19471-1-ming.lei@redhat.com>
 <20181126021720.19471-17-ming.lei@redhat.com>
 <20181126125842.GE6383@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126125842.GE6383@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Mon, Nov 26, 2018 at 01:58:42PM +0100, Christoph Hellwig wrote:
> > +		phys_addr_t vec_end_addr = page_to_phys(bv->bv_page) +
> > +			bv->bv_offset + bv->bv_len;
> 
> The name is a little confusing, as the real end addr would be -1.  Maybe
> throw the -1 in here, and adjust for it in the contigous check below?

Yeah, it makes sense.

thanks,
Ming
