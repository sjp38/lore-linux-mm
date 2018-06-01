Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 32DA36B0005
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 19:56:16 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id i64-v6so25010490qkh.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 16:56:16 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x18-v6si10143559qva.53.2018.06.01.16.56.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jun 2018 16:56:15 -0700 (PDT)
Date: Sat, 2 Jun 2018 07:55:54 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [RESEND PATCH V5 00/33] block: support multipage bvec
Message-ID: <20180601235553.GB655@ming.t460p>
References: <20180525034621.31147-1-ming.lei@redhat.com>
 <20180525045306.GB8740@kmo-pixel>
 <8aa4276d-c0bc-3266-aa53-bf08a2e5ab5c@kernel.dk>
 <20180527072332.GA18240@ming.t460p>
 <cc266632-497c-6849-e291-4f042c8d987a@kernel.dk>
 <20180528023042.GC26790@ming.t460p>
 <20180601084302.GB30694@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180601084302.GB30694@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@kernel.dk>, Kent Overstreet <kent.overstreet@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>

On Fri, Jun 01, 2018 at 01:43:02AM -0700, Christoph Hellwig wrote:
> On Mon, May 28, 2018 at 10:30:43AM +0800, Ming Lei wrote:
> > I hate the conversion too, but looks it can't be avoided since
> > bio_for_each_segment_all() has to be changed.
> 
> I guess you mean what is currently bio_for_each_page_all in your
> tree which now takes a bvec_iter_all agument?  We could just
> try to hide the bia variable initially under an unlike to be used
> name, and then slowly move to the proper bio_for_each_page_all
> API unhiding it with the rename.

I tried that way at the beginning, it will cause gcc warning, since
the variable will be defined in the middle of one function, and even
worse it might break nested iterator case.

Thanks,
Ming
