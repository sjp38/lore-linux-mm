Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8206B099D
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 08:38:46 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id j90-v6so26836427wrj.20
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 05:38:46 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id q12-v6si24154825wrr.127.2018.11.16.05.38.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 05:38:45 -0800 (PST)
Date: Fri, 16 Nov 2018 14:38:45 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V10 08/19] btrfs: move bio_pages_all() to btrfs
Message-ID: <20181116133845.GG3165@lst.de>
References: <20181115085306.9910-1-ming.lei@redhat.com> <20181115085306.9910-9-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-9-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:52:55PM +0800, Ming Lei wrote:
> BTRFS is the only user of this helper, so move this helper into
> BTRFS, and implement it via bio_for_each_segment_all(), since
> bio->bi_vcnt may not equal to number of pages after multipage bvec
> is enabled.

btrfs only uses the value to check if it is larger than 1.  No amount
of multipage bio merging should ever make bi_vcnt go from 0 to 1 or
vice versa.
