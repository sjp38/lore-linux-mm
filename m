Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3E7026B0278
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 03:37:03 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id uc5so1293690pab.10
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 00:37:03 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id l20si1001694pag.63.2016.10.26.00.36.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 00:36:58 -0700 (PDT)
Date: Wed, 26 Oct 2016 00:36:48 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCHv4 18/43] block: define BIO_MAX_PAGES to HPAGE_PMD_NR if
 huge page cache enabled
Message-ID: <20161026073648.GC1128@infradead.org>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
 <20161025001342.76126-19-kirill.shutemov@linux.intel.com>
 <20161025072122.GA21708@infradead.org>
 <20161025125431.GA22787@node.shutemov.name>
 <BD27B76A-AF34-48B9-8D4F-F69AD2C17C66@dilger.ca>
 <CACVXFVOYXJW1c8LHiwoM9a0nLnkeeGVPUZRvs2=MohFwvhugsQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACVXFVOYXJW1c8LHiwoM9a0nLnkeeGVPUZRvs2=MohFwvhugsQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <tom.leiming@gmail.com>
Cc: Andreas Dilger <adilger@dilger.ca>, "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Hellwig <hch@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-block <linux-block@vger.kernel.org>

On Wed, Oct 26, 2016 at 03:30:05PM +0800, Ming Lei wrote:
> I am preparing for the multipage bvec support[1], and once it is ready the
> default 256 bvecs should be enough for normal cases.

Yes, multipage bvecs are defintively the way to got to efficiently
support I/O on huge pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
