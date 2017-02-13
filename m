Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id AA60D6B0387
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 11:01:28 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id x75so68215261vke.5
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 08:01:28 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n83si10442201pfj.15.2017.02.13.08.01.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 08:01:27 -0800 (PST)
Date: Mon, 13 Feb 2017 08:01:17 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCHv6 08/37] filemap: handle huge pages in
 do_generic_file_read()
Message-ID: <20170213160117.GA6416@bombadil.infradead.org>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
 <20170126115819.58875-9-kirill.shutemov@linux.intel.com>
 <20170209215505.GW2267@bombadil.infradead.org>
 <20170213153342.GE20394@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170213153342.GE20394@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Mon, Feb 13, 2017 at 06:33:42PM +0300, Kirill A. Shutemov wrote:
> No. pagecache_get_page() returns subpage. See description of the first
> patch.

Your description says:

> We also change interface for page-cache lookup function:
> 
>   - functions that lookup for pages[1] would return subpages of THP
>     relevant for requested indexes;
> 
>   - functions that lookup for entries[2] would return one entry per-THP
>     and index will point to index of head page (basically, round down to
>     HPAGE_PMD_NR);
> 
> This would provide balanced exposure of multi-order entires to the rest
> of the kernel.
> 
> [1] find_get_pages(), pagecache_get_page(), pagevec_lookup(), etc.
> [2] find_get_entry(), find_get_entries(), pagevec_lookup_entries(), etc.

I'm saying:

> > We got this page from find_get_page(), which gets it from
> > pagecache_get_page(), which gets it from find_get_entry() ... which
> > (unless I'm lost in your patch series) returns the head page.

Am I guilty of debugging documentation rather than code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
