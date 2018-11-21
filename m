Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id F2CF76B264D
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 11:08:13 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id y1so6797239wrd.7
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 08:08:13 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id x125si1123953wmg.68.2018.11.21.08.08.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 08:08:12 -0800 (PST)
Date: Wed, 21 Nov 2018 17:08:11 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V11 02/19] block: introduce multi-page bvec helpers
Message-ID: <20181121160811.GA4977@lst.de>
References: <20181121032327.8434-1-ming.lei@redhat.com> <20181121032327.8434-3-ming.lei@redhat.com> <20181121131928.GA1640@lst.de> <20181121150610.GA19111@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121150610.GA19111@ming.t460p>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Wed, Nov 21, 2018 at 11:06:11PM +0800, Ming Lei wrote:
> bvec_iter_* is used for single-page bvec in current linus tree, and there are
> lots of users now:
> 
> [linux]$ git grep -n "bvec_iter_*" ./ | wc
>     191     995   13242
> 
> If we have to switch it first, it can be a big change, just wondering if Jens
> is happy with that?

Your above grep statement seems to catch every use of struct bvec_iter,
due to the *.

Most uses of bvec_iter_ are either in the block headers, or are
ceph wrappers that match the above and can easily be redefined.
