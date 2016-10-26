Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 310B56B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 03:36:29 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i85so149519305pfa.5
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 00:36:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id q9si1165657pgc.165.2016.10.26.00.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 00:36:28 -0700 (PDT)
Date: Wed, 26 Oct 2016 00:36:19 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCHv4 18/43] block: define BIO_MAX_PAGES to HPAGE_PMD_NR if
 huge page cache enabled
Message-ID: <20161026073619.GB1128@infradead.org>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
 <20161025001342.76126-19-kirill.shutemov@linux.intel.com>
 <20161025072122.GA21708@infradead.org>
 <20161025125431.GA22787@node.shutemov.name>
 <BD27B76A-AF34-48B9-8D4F-F69AD2C17C66@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BD27B76A-AF34-48B9-8D4F-F69AD2C17C66@dilger.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Hellwig <hch@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Tue, Oct 25, 2016 at 10:13:13PM -0600, Andreas Dilger wrote:
> Why wouldn't you have all the pool sizes in between?  Definitely 1MB has
> been too small already for high-bandwidth IO.  I wouldn't mind BIOs up to
> 4MB or larger since most high-end RAID hardware does best with 4MB IOs.

I/O sizes are not limited by the bio size, we can already support larger
than 1MB I/O for a long time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
