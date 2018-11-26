Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA2486B3F6B
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 07:58:44 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id z16so2136762wrt.5
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 04:58:44 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t184-v6si573198wmg.148.2018.11.26.04.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 04:58:43 -0800 (PST)
Date: Mon, 26 Nov 2018 13:58:42 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V12 16/20] block: enable multipage bvecs
Message-ID: <20181126125842.GE6383@lst.de>
References: <20181126021720.19471-1-ming.lei@redhat.com> <20181126021720.19471-17-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126021720.19471-17-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

> +		phys_addr_t vec_end_addr = page_to_phys(bv->bv_page) +
> +			bv->bv_offset + bv->bv_len;

The name is a little confusing, as the real end addr would be -1.  Maybe
throw the -1 in here, and adjust for it in the contigous check below?
