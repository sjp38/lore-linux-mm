Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4E20E6B0005
	for <linux-mm@kvack.org>; Thu, 14 Jun 2018 02:39:40 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id x6-v6so1768622pgp.9
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 23:39:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n5-v6si4591745pfi.360.2018.06.13.23.39.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Jun 2018 23:39:39 -0700 (PDT)
Date: Wed, 13 Jun 2018 23:39:20 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V6 15/30] block: introduce bio_clone_chunk_bioset()
Message-ID: <20180614063920.GA10284@infradead.org>
References: <20180609123014.8861-1-ming.lei@redhat.com>
 <20180609123014.8861-16-ming.lei@redhat.com>
 <20180613145654.GE4693@infradead.org>
 <20180614020137.GF19828@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180614020137.GF19828@ming.t460p>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

On Thu, Jun 14, 2018 at 10:01:38AM +0800, Ming Lei wrote:
> Bounce limits the max pages as 256 will do bio splitting, so won't need
> this change.

Behavior for the bounce code does not change with my patch.

The important points are:

 - the default interface (bio_clone_bioset in this case) should always
   operate on full biosets
 - if the bounce code needs bioves limited to single pages it should
   be treated as the special case
 - given that the bounce code is inside the block layer using the
   __-prefixed internal interface is perfectly fine
 - last but not least I think the parameter switching the behavior
   needs a much more descriptive name as suggested in my patch
