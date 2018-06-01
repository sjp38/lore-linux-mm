Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 48C2E6B0007
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 04:36:18 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f10-v6so14887773pln.21
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 01:36:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c83-v6si17121625pfl.319.2018.06.01.01.36.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Jun 2018 01:36:15 -0700 (PDT)
Date: Fri, 1 Jun 2018 01:35:57 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RESEND PATCH V5 00/33] block: support multipage bvec
Message-ID: <20180601083557.GA30694@infradead.org>
References: <20180525034621.31147-1-ming.lei@redhat.com>
 <20180525045306.GB8740@kmo-pixel>
 <8aa4276d-c0bc-3266-aa53-bf08a2e5ab5c@kernel.dk>
 <20180527072332.GA18240@ming.t460p>
 <cc266632-497c-6849-e291-4f042c8d987a@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cc266632-497c-6849-e291-4f042c8d987a@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Ming Lei <ming.lei@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>

On Sun, May 27, 2018 at 07:44:52PM -0600, Jens Axboe wrote:
> Yes, we discussed exactly this, which is why I'm surprised you went
> ahead with the same approach. I told you I don't like tree wide renames,
> if they can be avoided. I'd rather suffer some pain wrt page vs segments
> naming, and then later do a rename (if it bothers us) once the dust has
> settled on the interesting part of the changes.
> 
> I'm very well away of our current naming and what it signifies.  With
> #1, you are really splitting hairs, imho. Find a decent name for
> multiple segment. Chunk?

vec?

bio_for_each_segment (page)
bio_for_each_vec (whole bvec)
