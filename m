Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id D80CD6B025E
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 13:29:48 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id u134so27680753ywg.2
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 10:29:48 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id k130si476960ywb.42.2016.07.26.10.29.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 10:29:47 -0700 (PDT)
Date: Tue, 26 Jul 2016 13:29:38 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCHv1, RFC 00/33] ext4: support of huge pages
Message-ID: <20160726172938.GA9284@thunk.org>
References: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Tue, Jul 26, 2016 at 03:35:02AM +0300, Kirill A. Shutemov wrote:
> Here's the first version of my patchset which intended to bring huge pages
> to ext4. It's not yet ready for applying or serious use, but good enough
> to show the approach.

Thanks.  The major issues I noticed when doing a quick scan of the
patches you've already mentioned here.  I'll try to take a closer look
in the next week or so when I have time.

One random question --- in the huge=always approach, how much
additional work would be needed to support file systems with a 64k
block size on a system with 4k pages?

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
