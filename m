Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id ABF106B0007
	for <linux-mm@kvack.org>; Thu, 14 Jun 2018 03:28:49 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id k7-v6so4058419qtm.1
        for <linux-mm@kvack.org>; Thu, 14 Jun 2018 00:28:49 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s29-v6si3471053qki.146.2018.06.14.00.28.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jun 2018 00:28:48 -0700 (PDT)
Date: Thu, 14 Jun 2018 15:28:29 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V6 15/30] block: introduce bio_clone_chunk_bioset()
Message-ID: <20180614072828.GA26621@ming.t460p>
References: <20180609123014.8861-1-ming.lei@redhat.com>
 <20180609123014.8861-16-ming.lei@redhat.com>
 <20180613145654.GE4693@infradead.org>
 <20180614020137.GF19828@ming.t460p>
 <20180614063920.GA10284@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180614063920.GA10284@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

On Wed, Jun 13, 2018 at 11:39:20PM -0700, Christoph Hellwig wrote:
> On Thu, Jun 14, 2018 at 10:01:38AM +0800, Ming Lei wrote:
> > Bounce limits the max pages as 256 will do bio splitting, so won't need
> > this change.
> 
> Behavior for the bounce code does not change with my patch.
> 
> The important points are:
> 
>  - the default interface (bio_clone_bioset in this case) should always
>    operate on full biosets
>  - if the bounce code needs bioves limited to single pages it should
>    be treated as the special case
>  - given that the bounce code is inside the block layer using the
>    __-prefixed internal interface is perfectly fine
>  - last but not least I think the parameter switching the behavior
>    needs a much more descriptive name as suggested in my patch

Fair enough, will switch to this way and avoid DM's change, even though
it is a dying interface.

Thanks,
Ming
