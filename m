Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BBEA26B0007
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 21:34:17 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z6so3283302pgu.20
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 18:34:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a33-v6si3286653pli.275.2018.04.20.18.34.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 20 Apr 2018 18:34:16 -0700 (PDT)
Date: Fri, 20 Apr 2018 18:34:06 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v11 10/63] xarray: Add xa_for_each
Message-ID: <20180421013406.GM10788@bombadil.infradead.org>
References: <20180414141316.7167-1-willy@infradead.org>
 <20180414141316.7167-11-willy@infradead.org>
 <35a3318d-69d7-a10c-1515-98ea6b59fb99@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35a3318d-69d7-a10c-1515-98ea6b59fb99@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Fri, Apr 20, 2018 at 07:00:47AM -0500, Goldwyn Rodrigues wrote:
> > +/**
> > + * xas_for_each_tag() - Iterate over a range of an XArray
> > + * @xas: XArray operation state.
> > + * @entry: Entry retrieved from array.
> > + * @max: Maximum index to retrieve from array.
> > + * @tag: Tag to search for.
> > + *
> > + * The loop body will be executed for each tagged entry in the xarray
> > + * between the current xas position and @max.  @entry will be set to
> > + * the entry retrieved from the xarray.  It is safe to delete entries
> > + * from the array in the loop body.  You should hold either the RCU lock
> > + * or the xa_lock while iterating.  If you need to drop the lock, call
> > + * xas_pause() first.
> > + */
> > +#define xas_for_each_tag(xas, entry, max, tag) \
> > +	for (entry = xas_find_tag(xas, max, tag); entry; \
> > +	     entry = xas_next_tag(xas, max, tag))
> > +
> 
> This function name sounds like you are performing the operation for each
> tag.
> 
> Can it be called xas_for_each_tagged() or xas_tag_for_each() instead?

I hadn't thought of that interpretation.  Yes, that makes sense.
Should we also rename xas_find_tag -> xas_find_tagged and xas_next_tag
-> xas_next_tagged?
