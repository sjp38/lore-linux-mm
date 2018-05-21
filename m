Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C23CE6B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 06:11:47 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e16-v6so9041620pfn.5
        for <linux-mm@kvack.org>; Mon, 21 May 2018 03:11:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p8-v6si10856332pgs.441.2018.05.21.03.11.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 21 May 2018 03:11:45 -0700 (PDT)
Date: Mon, 21 May 2018 03:11:39 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v11 53/63] dax: Rename some functions
Message-ID: <20180521101139.GA20878@bombadil.infradead.org>
References: <20180414141316.7167-1-willy@infradead.org>
 <20180414141316.7167-54-willy@infradead.org>
 <20180521044236.GC27043@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180521044236.GC27043@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Sun, May 20, 2018 at 10:42:36PM -0600, Ross Zwisler wrote:
> > -static void *dax_radix_locked_entry(unsigned long pfn, unsigned long flags)
> > +static void *dax_mk_locked(unsigned long pfn, unsigned long flags)
> 
> Let's continue to use whole words in function names instead of abbreviations
> for readability.  Can you please s/dax_mk_locked/dax_make_locked/ ?
> 
> I do realize that the xarray function is xa_mk_value() (which I also think is
> perhaps too brief for readability), but in the rest of DAX we use full words
> everywhere.

I find the current DAX code to be _so_ wordy that it obscures readability.
This particular instance isn't a hill worth dying on; I'll change it.

> > @@ -1519,15 +1517,14 @@ int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
> >  }
> >  EXPORT_SYMBOL_GPL(dax_iomap_fault);
> >  
> > -/**
> > +/*
> 
> Let's leave the double ** so that the function is picked up properly by
> the documentation system, and so it's consistent with the rest of the
> functions.

This function is static.  I think it's worth keeping the documentation,
but making it part of the exported kernel API documentation is confusing.

By the way, nothing at all in fs/dax.c is picked up by the documentation
system today.  We should probably fix that ... did you want to look at it
or shall I propose a patch to anchor it somewhere?
