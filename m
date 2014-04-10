Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id D12BE6B0039
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 10:28:12 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id p10so3934952pdj.12
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 07:28:12 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id zt8si2301552pbc.402.2014.04.10.07.28.11
        for <linux-mm@kvack.org>;
        Thu, 10 Apr 2014 07:28:11 -0700 (PDT)
Date: Thu, 10 Apr 2014 10:27:29 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 18/22] xip: Add xip_zero_page_range
Message-ID: <20140410142729.GL5727@linux.intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <5a87acda8c3e4d2b7ea5dd1249fcbf8be23b9645.1395591795.git.matthew.r.wilcox@intel.com>
 <20140409101512.GL32103@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140409101512.GL32103@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed, Apr 09, 2014 at 12:15:12PM +0200, Jan Kara wrote:
> > +		/*
> > +		 * ext4 sometimes asks to zero past the end of a block.  It
> > +		 * really just wants to zero to the end of the block.
> > +		 */
>   Then we should really fix ext4 I believe...

Since I didn't want to do this ...

> > +/* Can't be a function because PAGE_CACHE_SIZE is defined in pagemap.h */
> > +#define dax_truncate_page(inode, from, get_block)	\
> > +	dax_zero_page_range(inode, from, PAGE_CACHE_SIZE, get_block)
>                                          ^^^^
> This should be (PAGE_CACHE_SIZE - (from & (PAGE_CACHE_SIZE - 1))), shouldn't it?

... I could get away without doing that ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
