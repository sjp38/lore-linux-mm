Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B4BF36B0038
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 08:59:53 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v77so42180310wmv.5
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:59:53 -0800 (PST)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id z11si5646447wmh.2.2017.02.13.05.59.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 05:59:52 -0800 (PST)
Received: by mail-wr0-x241.google.com with SMTP id k90so24199154wrc.3
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:59:52 -0800 (PST)
Date: Mon, 13 Feb 2017 16:59:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 03/37] page-flags: relax page flag policy for few flags
Message-ID: <20170213135950.GB20394@node.shutemov.name>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
 <20170126115819.58875-4-kirill.shutemov@linux.intel.com>
 <20170209040113.GR2267@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170209040113.GR2267@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Wed, Feb 08, 2017 at 08:01:13PM -0800, Matthew Wilcox wrote:
> On Thu, Jan 26, 2017 at 02:57:45PM +0300, Kirill A. Shutemov wrote:
> > These flags are in use for filesystems with backing storage: PG_error,
> > PG_writeback and PG_readahead.
> 
> Oh ;-)  Then I amend my comment on patch 1 to be "patch 3 needs to go
> ahead of patch 1" ;-)

It doesn't really matter as long as both before patch 37 :P

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
