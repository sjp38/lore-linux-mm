Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A8C56B0006
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 15:46:24 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id i1-v6so73852pld.11
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 12:46:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j6-v6si723935pgs.615.2018.06.12.12.46.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Jun 2018 12:46:23 -0700 (PDT)
Date: Tue, 12 Jun 2018 12:46:19 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v13 00/72] Convert page cache to XArray
Message-ID: <20180612194619.GH19433@bombadil.infradead.org>
References: <20180611140639.17215-1-willy@infradead.org>
 <20180612104041.GB24375@twin.jikos.cz>
 <20180612113122.GA19433@bombadil.infradead.org>
 <20180612193741.GC28436@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180612193741.GC28436@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, dsterba@suse.cz, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

On Tue, Jun 12, 2018 at 01:37:41PM -0600, Ross Zwisler wrote:
> On Tue, Jun 12, 2018 at 04:31:22AM -0700, Matthew Wilcox wrote:
> > On Tue, Jun 12, 2018 at 12:40:41PM +0200, David Sterba wrote:
> > > [ 9875.174796] kernel BUG at fs/inode.c:513!
> > 
> > What the ...
> > 
> > Somehow the fix for that got dropped.  I spent most of last week chasing
> > that problem!  This is the correct code:
> > 
> > http://git.infradead.org/users/willy/linux-dax.git/commitdiff/01177bb06761539af8a6c872416109e2c8b64559
> > 
> > I'll check over the patchset and see if anything else got dropped!
> 
> Can you please repost when you have this sorted?
> 
> I think the commit you've pointed to is in your xarray-20180601 branch, but I
> see two more recent xarray branches in your tree (xarray-20180608 and
> xarray-20180612).
> 
> Basically, I don't know what is stable and what's not, and what I should be
> reviewing/testing.

Yup, I shall.  The xarray-20180612 is the most recent thing I've
published, but I'm still going over the 0601 patchset looking for other
little pieces I may have dropped.  I've found a couple, and I'm updating
the 0612 branch each time I find another one.

If you want to start looking at the DAX patches on the 0612 branch,
that wouldn't be a waste of your time.  Neither would testing; I don't
think I dropped anything from the DAX patches.
