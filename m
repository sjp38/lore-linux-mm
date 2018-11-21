Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id C71E56B2674
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 11:12:08 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id p16so7921487wmc.5
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 08:12:08 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id f5-v6si39693170wrh.140.2018.11.21.08.12.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 08:12:07 -0800 (PST)
Date: Wed, 21 Nov 2018 17:12:06 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V11 15/19] block: enable multipage bvecs
Message-ID: <20181121161206.GD4977@lst.de>
References: <20181121032327.8434-1-ming.lei@redhat.com> <20181121032327.8434-16-ming.lei@redhat.com> <20181121145502.GA3241@lst.de> <20181121154812.GD19111@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121154812.GD19111@ming.t460p>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Wed, Nov 21, 2018 at 11:48:13PM +0800, Ming Lei wrote:
> I guess the correct check should be:
> 
> 		end_addr = vec_addr + bv->bv_offset + bv->bv_len;
> 		if (same_page &&
> 		    (end_addr & PAGE_MASK) != (page_addr & PAGE_MASK))
> 			return false;

Indeed.
