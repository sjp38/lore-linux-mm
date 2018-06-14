Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 09CD56B0005
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 22:01:58 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 84-v6so3759114qkz.3
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 19:01:58 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f1-v6si3737249qtp.48.2018.06.13.19.01.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 19:01:57 -0700 (PDT)
Date: Thu, 14 Jun 2018 10:01:38 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V6 15/30] block: introduce bio_clone_chunk_bioset()
Message-ID: <20180614020137.GF19828@ming.t460p>
References: <20180609123014.8861-1-ming.lei@redhat.com>
 <20180609123014.8861-16-ming.lei@redhat.com>
 <20180613145654.GE4693@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180613145654.GE4693@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

On Wed, Jun 13, 2018 at 07:56:54AM -0700, Christoph Hellwig wrote:
> On Sat, Jun 09, 2018 at 08:29:59PM +0800, Ming Lei wrote:
> > There is one use case(DM) which requires to clone bio chunk by
> > chunk, so introduce this API.
> 
> I don't think DM is the special case here.  The special case is the
> bounce code that only wants single page bios.  Between that, and the
> fact that we only have two callers and one of them is inside the
> block layer I would suggest to fold in the following patch to make
> bio_clone_bioset clone in multi-page bvecs and make the bounce code
> use the low-level interface directly:

Bounce limits the max pages as 256 will do bio splitting, so won't need
this change.


Thanks,
Ming
