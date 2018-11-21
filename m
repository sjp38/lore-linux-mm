Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id C1ABD6B2588
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 09:34:45 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id y74so13693179wmc.0
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 06:34:45 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id p65-v6si924094wmp.160.2018.11.21.06.34.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 06:34:44 -0800 (PST)
Date: Wed, 21 Nov 2018 15:34:44 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V11 17/19] block: document usage of bio iterator helpers
Message-ID: <20181121143443.GC2594@lst.de>
References: <20181121032327.8434-1-ming.lei@redhat.com> <20181121032327.8434-18-ming.lei@redhat.com> <1f93e845-09e8-2c6c-3643-654b8c490597@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1f93e845-09e8-2c6c-3643-654b8c490597@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <nborisov@suse.com>
Cc: Ming Lei <ming.lei@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Wed, Nov 21, 2018 at 09:45:25AM +0200, Nikolay Borisov wrote:
> > +	bio_for_each_segment_all()
> > +	bio_first_bvec_all()
> > +	bio_first_page_all()
> > +	bio_last_bvec_all()
> > +
> > +* The following helpers iterate over single-page bvecs. The passed 'struct
> > +bio_vec' will contain a single-page IO vector during the iteration
> > +
> > +	bio_for_each_segment()
> > +	bio_for_each_segment_all()
> > +
> > +* The following helpers iterate over single-page bvecs. The passed 'struct
> > +bio_vec' will contain a single-page IO vector during the iteration
> > +
> > +	bio_for_each_bvec()
> 
> Just put this helper right below the above 2, no need to repeat the
> explanation. Also I'd suggest introducing another catch-all sentence
> "All other helpers are assumed to iterate multipage bio vecs" and
> perhaps give an example with 1-2 helpers.

Well, I think the second explanation is wrong - bio_for_each_bvec
iterates over the whole bvecs, not just single page.
