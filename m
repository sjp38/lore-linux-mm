Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4312A6B0A48
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 11:04:38 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b88-v6so19421994pfj.4
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 08:04:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i62-v6sor39176269pfi.15.2018.11.16.08.04.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Nov 2018 08:04:37 -0800 (PST)
Date: Fri, 16 Nov 2018 08:04:33 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V10 03/19] block: use bio_for_each_bvec() to compute
 multi-page bvec count
Message-ID: <20181116160433.GV23828@vader>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-4-ming.lei@redhat.com>
 <20181115202028.GC9348@vader>
 <20181115210510.GA24908@redhat.com>
 <20181115221847.GD9348@vader>
 <20181116091956.GA17604@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116091956.GA17604@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Mike Snitzer <snitzer@redhat.com>, Ming Lei <ming.lei@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Fri, Nov 16, 2018 at 10:19:56AM +0100, Christoph Hellwig wrote:
> On Thu, Nov 15, 2018 at 02:18:47PM -0800, Omar Sandoval wrote:
> > My only reason to prefer unsigned int is consistency. unsigned int is
> > much more common in the kernel:
> > 
> > $ ag --cc -s 'unsigned\s+int' | wc -l
> > 129632
> > $ ag --cc -s 'unsigned\s+(?!char|short|int|long)' | wc -l
> > 22435
> > 
> > checkpatch also warns on plain unsigned.
> 
> Talk about chicken and egg.  unsigned is perfectly valid C, and being
> shorter often helps being more readable.  checkpath is as so often
> wrongly opinionated..

Fair enough. Since enough people don't mind bare unsigned in the block
code, I retract my comment :)
