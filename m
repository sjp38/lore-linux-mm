Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 96E936B09CD
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 08:49:38 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id o9-v6so26962234wrw.2
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 05:49:38 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id s18si3388321wro.429.2018.11.16.05.49.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 05:49:37 -0800 (PST)
Date: Fri, 16 Nov 2018 14:49:36 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V10 13/19] iomap & xfs: only account for new added page
Message-ID: <20181116134936.GJ3165@lst.de>
References: <20181115085306.9910-1-ming.lei@redhat.com> <20181115085306.9910-14-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-14-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

I'd much rather have __bio_try_merge_page only do merges in
the same page, and have a new __bio_try_merge_segment that does
multi-page merges.  This will keep the accounting a lot simpler.
