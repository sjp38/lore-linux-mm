Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id D541F6B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 03:36:00 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id xx10so1362437pac.2
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 00:36:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ro4si1001080pab.36.2016.10.26.00.36.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 00:36:00 -0700 (PDT)
Date: Wed, 26 Oct 2016 00:35:43 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCHv4 18/43] block: define BIO_MAX_PAGES to HPAGE_PMD_NR if
 huge page cache enabled
Message-ID: <20161026073543.GA1128@infradead.org>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
 <20161025001342.76126-19-kirill.shutemov@linux.intel.com>
 <20161025072122.GA21708@infradead.org>
 <20161025125431.GA22787@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161025125431.GA22787@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Christoph Hellwig <hch@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Tue, Oct 25, 2016 at 03:54:31PM +0300, Kirill A. Shutemov wrote:
> The size of required pool depends on architecture: different architectures
> has different (huge page size)/(base page size).

Please explain first why they are required and not just nice to have.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
