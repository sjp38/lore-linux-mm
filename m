Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5396C6B0005
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 04:43:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j14-v6so14168730pfn.11
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 01:43:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p3-v6si37943897pff.356.2018.06.01.01.43.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Jun 2018 01:43:16 -0700 (PDT)
Date: Fri, 1 Jun 2018 01:43:02 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RESEND PATCH V5 00/33] block: support multipage bvec
Message-ID: <20180601084302.GB30694@infradead.org>
References: <20180525034621.31147-1-ming.lei@redhat.com>
 <20180525045306.GB8740@kmo-pixel>
 <8aa4276d-c0bc-3266-aa53-bf08a2e5ab5c@kernel.dk>
 <20180527072332.GA18240@ming.t460p>
 <cc266632-497c-6849-e291-4f042c8d987a@kernel.dk>
 <20180528023042.GC26790@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180528023042.GC26790@ming.t460p>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, Kent Overstreet <kent.overstreet@gmail.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>

On Mon, May 28, 2018 at 10:30:43AM +0800, Ming Lei wrote:
> I hate the conversion too, but looks it can't be avoided since
> bio_for_each_segment_all() has to be changed.

I guess you mean what is currently bio_for_each_page_all in your
tree which now takes a bvec_iter_all agument?  We could just
try to hide the bia variable initially under an unlike to be used
name, and then slowly move to the proper bio_for_each_page_all
API unhiding it with the rename.

But I think your current bio_for_each_segment_all should just
go away.  All three users really should be using better abstractions.
