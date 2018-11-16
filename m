Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id EAE656B08B3
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 04:19:58 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id j10so7728889wrt.11
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 01:19:58 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id i11-v6si23910078wrn.60.2018.11.16.01.19.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 01:19:57 -0800 (PST)
Date: Fri, 16 Nov 2018 10:19:56 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V10 03/19] block: use bio_for_each_bvec() to compute
 multi-page bvec count
Message-ID: <20181116091956.GA17604@lst.de>
References: <20181115085306.9910-1-ming.lei@redhat.com> <20181115085306.9910-4-ming.lei@redhat.com> <20181115202028.GC9348@vader> <20181115210510.GA24908@redhat.com> <20181115221847.GD9348@vader>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115221847.GD9348@vader>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Ming Lei <ming.lei@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 02:18:47PM -0800, Omar Sandoval wrote:
> My only reason to prefer unsigned int is consistency. unsigned int is
> much more common in the kernel:
> 
> $ ag --cc -s 'unsigned\s+int' | wc -l
> 129632
> $ ag --cc -s 'unsigned\s+(?!char|short|int|long)' | wc -l
> 22435
> 
> checkpatch also warns on plain unsigned.

Talk about chicken and egg.  unsigned is perfectly valid C, and being
shorter often helps being more readable.  checkpath is as so often
wrongly opinionated..
