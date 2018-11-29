Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 593DD6B5073
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 22:31:21 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id b16so531938qtc.22
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 19:31:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u37si405733qta.385.2018.11.28.19.31.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 19:31:20 -0800 (PST)
Date: Thu, 29 Nov 2018 11:30:47 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V12 00/20] block: support multi-page bvec
Message-ID: <20181129033046.GE23390@ming.t460p>
References: <20181126021720.19471-1-ming.lei@redhat.com>
 <7096bc4e-0617-29d0-a90d-ae7caf09a16d@kernel.dk>
 <20181129012959.GC23249@ming.t460p>
 <1983a2f5-07be-4102-fedc-54e2ad2e16dc@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1983a2f5-07be-4102-fedc-54e2ad2e16dc@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Mike Snitzer <snitzer@redhat.com>, "Ewan D. Milne" <emilne@redhat.com>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Wed, Nov 28, 2018 at 07:20:51PM -0700, Jens Axboe wrote:
> On 11/28/18 6:30 PM, Ming Lei wrote:
> >> I'm going back and forth on those one a bit. Any concerns with
> >> pushing this to 4.22?
> > 
> > My only one concern is about the warning of
> > "blk_cloned_rq_check_limits: over max segments limit" on dm multipath,
> > and seems Ewan and Mike is waiting for this fix.
> 
> Not familiar with this issue, can you post a link to it? I'd be fine
> working around anything until 4.22, it's not going to be a new issue.

https://marc.info/?t=153303425700002&r=1&w=2

thanks,
Ming
