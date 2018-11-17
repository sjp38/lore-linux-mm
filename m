Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id B59586B0CC6
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 21:42:45 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id w185so56322245qka.9
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 18:42:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p33si333131qte.43.2018.11.16.18.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 18:42:45 -0800 (PST)
Date: Sat, 17 Nov 2018 10:42:11 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V10 00/19] block: support multi-page bvec
Message-ID: <20181117024209.GD8872@ming.t460p>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181116140314.GA7735@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116140314.GA7735@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Fri, Nov 16, 2018 at 03:03:14PM +0100, Christoph Hellwig wrote:
> It seems like bi_phys_segments is still around of this series.
> Shouldn't it be superflous now?

Even though multi-page bvec is supported, the segment number doesn't
equal to the actual bvec count yet, for example, one bvec may be too
bigger to be held in one single segment.


Thanks,
Ming
