Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 531176B1989
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 03:19:52 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id z126so67487093qka.10
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 00:19:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 99si6462907qta.389.2018.11.19.00.19.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 00:19:51 -0800 (PST)
Date: Mon, 19 Nov 2018 16:19:24 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V10 08/19] btrfs: move bio_pages_all() to btrfs
Message-ID: <20181119081922.GB16736@ming.t460p>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-9-ming.lei@redhat.com>
 <20181116133845.GG3165@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116133845.GG3165@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Fri, Nov 16, 2018 at 02:38:45PM +0100, Christoph Hellwig wrote:
> On Thu, Nov 15, 2018 at 04:52:55PM +0800, Ming Lei wrote:
> > BTRFS is the only user of this helper, so move this helper into
> > BTRFS, and implement it via bio_for_each_segment_all(), since
> > bio->bi_vcnt may not equal to number of pages after multipage bvec
> > is enabled.
> 
> btrfs only uses the value to check if it is larger than 1.  No amount
> of multipage bio merging should ever make bi_vcnt go from 0 to 1 or
> vice versa.

Could you explain a bit why?

Suppose 2 physically continuous pages are added to this bio, .bi_vcnt
can be 1 in case of multi-page bvec, but it is 2 in case of single-page
bvec.

Thanks,
Ming
