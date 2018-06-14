Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0126B000A
	for <linux-mm@kvack.org>; Thu, 14 Jun 2018 02:20:35 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r8-v6so1750992pgq.2
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 23:20:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k191-v6si3927483pgd.19.2018.06.13.23.20.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Jun 2018 23:20:33 -0700 (PDT)
Date: Wed, 13 Jun 2018 23:20:22 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V6 11/30] block: implement bio_pages_all() via
 bio_for_each_segment_all()
Message-ID: <20180614062022.GB3336@infradead.org>
References: <20180609123014.8861-1-ming.lei@redhat.com>
 <20180609123014.8861-12-ming.lei@redhat.com>
 <20180613144412.GB4693@infradead.org>
 <20180614012352.GC19828@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180614012352.GC19828@ming.t460p>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

On Thu, Jun 14, 2018 at 09:23:54AM +0800, Ming Lei wrote:
> On Wed, Jun 13, 2018 at 07:44:12AM -0700, Christoph Hellwig wrote:
> > Given that we have a single, dubious user of bio_pages_all I'd rather
> > see it as an opencoded bio_for_each_ loop in the caller.
> 
> Yeah, that is fine since there is only one user in btrfs.

And I suspect it really is checking for the wrong thing.  I don't
fully understand that code, but as far as I can tell it really
needs to know if there is more than a file system block of data in
the bio, and btrfs conflats pages with blocks.  But I'd need btrfs
folks to confirm this.
