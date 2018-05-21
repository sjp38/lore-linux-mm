Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1253A6B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 00:42:39 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 89-v6so9257379plb.18
        for <linux-mm@kvack.org>; Sun, 20 May 2018 21:42:39 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id t23-v6si263385pgb.465.2018.05.20.21.42.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 May 2018 21:42:37 -0700 (PDT)
Date: Sun, 20 May 2018 22:42:36 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v11 53/63] dax: Rename some functions
Message-ID: <20180521044236.GC27043@linux.intel.com>
References: <20180414141316.7167-1-willy@infradead.org>
 <20180414141316.7167-54-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180414141316.7167-54-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Sat, Apr 14, 2018 at 07:13:06AM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Remove mentions of 'radix' and 'radix tree'.  Simplify some names by
> dropping the word 'mapping'.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>


> @@ -74,18 +74,18 @@ fs_initcall(init_dax_wait_table);
>  #define DAX_ZERO_PAGE	(1UL << 2)
>  #define DAX_EMPTY	(1UL << 3)
>  
> -static unsigned long dax_radix_pfn(void *entry)
> +static unsigned long dax_to_pfn(void *entry)
>  {
>  	return xa_to_value(entry) >> DAX_SHIFT;
>  }
>  
> -static void *dax_radix_locked_entry(unsigned long pfn, unsigned long flags)
> +static void *dax_mk_locked(unsigned long pfn, unsigned long flags)

Let's continue to use whole words in function names instead of abbreviations
for readability.  Can you please s/dax_mk_locked/dax_make_locked/ ?

I do realize that the xarray function is xa_mk_value() (which I also think is
perhaps too brief for readability), but in the rest of DAX we use full words
everywhere.

> @@ -1519,15 +1517,14 @@ int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
>  }
>  EXPORT_SYMBOL_GPL(dax_iomap_fault);
>  
> -/**
> +/*

Let's leave the double ** so that the function is picked up properly by
the documentation system, and so it's consistent with the rest of the
functions.
