Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EF2516B026C
	for <linux-mm@kvack.org>; Tue, 22 May 2018 17:39:58 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e20-v6so11931791pff.14
        for <linux-mm@kvack.org>; Tue, 22 May 2018 14:39:58 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id u62-v6si13113005pgc.180.2018.05.22.14.39.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 14:39:58 -0700 (PDT)
Date: Tue, 22 May 2018 15:39:55 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v11 53/63] dax: Rename some functions
Message-ID: <20180522213955.GB12733@linux.intel.com>
References: <20180414141316.7167-1-willy@infradead.org>
 <20180414141316.7167-54-willy@infradead.org>
 <20180521044236.GC27043@linux.intel.com>
 <20180521101139.GA20878@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180521101139.GA20878@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Mon, May 21, 2018 at 03:11:39AM -0700, Matthew Wilcox wrote:
> On Sun, May 20, 2018 at 10:42:36PM -0600, Ross Zwisler wrote:

> > > @@ -1519,15 +1517,14 @@ int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
> > >  }
> > >  EXPORT_SYMBOL_GPL(dax_iomap_fault);
> > >  
> > > -/**
> > > +/*
> > 
> > Let's leave the double ** so that the function is picked up properly by
> > the documentation system, and so it's consistent with the rest of the
> > functions.
> 
> This function is static.  I think it's worth keeping the documentation,
> but making it part of the exported kernel API documentation is confusing.

Ah, fair enough.

> By the way, nothing at all in fs/dax.c is picked up by the documentation
> system today.  We should probably fix that ... did you want to look at it
> or shall I propose a patch to anchor it somewhere?

If you have time for it that would be awesome.
