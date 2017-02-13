Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 80E826B0387
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 11:10:20 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id q3so106957770qtf.4
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 08:10:20 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s5si10408283pgo.231.2017.02.13.08.10.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 08:10:19 -0800 (PST)
Date: Mon, 13 Feb 2017 08:09:59 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCHv6 08/37] filemap: handle huge pages in
 do_generic_file_read()
Message-ID: <20170213160959.GB6416@bombadil.infradead.org>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
 <20170126115819.58875-9-kirill.shutemov@linux.intel.com>
 <20170209215505.GW2267@bombadil.infradead.org>
 <20170213153342.GE20394@node.shutemov.name>
 <20170213160117.GA6416@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170213160117.GA6416@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Mon, Feb 13, 2017 at 08:01:17AM -0800, Matthew Wilcox wrote:
> On Mon, Feb 13, 2017 at 06:33:42PM +0300, Kirill A. Shutemov wrote:
> > No. pagecache_get_page() returns subpage. See description of the first
> > patch.

Oh, I re-read patch 1 and it made sense now.  I missed the bit where
pagecache_get_page() called page_subpage().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
