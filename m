Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F25A6B2425
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 08:19:31 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id p12so6553659wrt.17
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 05:19:31 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id p65-v6si784874wmp.160.2018.11.21.05.19.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 05:19:29 -0800 (PST)
Date: Wed, 21 Nov 2018 14:19:28 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V11 02/19] block: introduce multi-page bvec helpers
Message-ID: <20181121131928.GA1640@lst.de>
References: <20181121032327.8434-1-ming.lei@redhat.com> <20181121032327.8434-3-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121032327.8434-3-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Wed, Nov 21, 2018 at 11:23:10AM +0800, Ming Lei wrote:
> This patch introduces helpers of 'segment_iter_*' for multipage
> bvec support.
> 
> The introduced helpers treate one bvec as real multi-page segment,
> which may include more than one pages.

Unless I'm missing something these bvec vs segment names are exactly
inverted vs how we use it elsewhere.

In the iterators we use segment for single-page bvec, and bvec for multi
page ones, and here it is inverse.  Please switch it around.
