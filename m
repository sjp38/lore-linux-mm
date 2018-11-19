Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id C88776B19D0
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 04:04:42 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id n68so67102165qkn.8
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 01:04:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b72si2779218qkh.258.2018.11.19.01.04.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 01:04:42 -0800 (PST)
Date: Mon, 19 Nov 2018 17:04:16 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V10 15/19] block: always define BIO_MAX_PAGES as 256
Message-ID: <20181119090415.GM16736@ming.t460p>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-16-ming.lei@redhat.com>
 <20181116015936.GJ23828@vader>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116015936.GJ23828@vader>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>, Huang Ying <ying.huang@intel.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 05:59:36PM -0800, Omar Sandoval wrote:
> On Thu, Nov 15, 2018 at 04:53:02PM +0800, Ming Lei wrote:
> > Now multi-page bvec can cover CONFIG_THP_SWAP, so we don't need to
> > increase BIO_MAX_PAGES for it.
> 
> You mentioned to it in the cover letter, but this needs more explanation
> in the commit message. Why did CONFIG_THP_SWAP require > 256? Why does
> multipage bvecs remove that requirement?

CONFIG_THP_SWAP needs to split one TH page into normal pages and adds
them all to one bio. With multipage-bvec, it just takes one bvec to
hold them all.

thanks,
Ming
