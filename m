Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 586E66B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 16:34:48 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id n8so4355277ybn.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 13:34:48 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id v203si2073332ywa.316.2016.08.12.13.34.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 13:34:47 -0700 (PDT)
Date: Fri, 12 Aug 2016 16:34:40 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCHv2, 00/41] ext4: support of huge pages
Message-ID: <20160812203440.GD30280@thunk.org>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Fri, Aug 12, 2016 at 09:37:43PM +0300, Kirill A. Shutemov wrote:
> Here's stabilized version of my patchset which intended to bring huge pages
> to ext4.

So this patch is more about mm level changes than it is about the file
system, and I didn't see any comments from the linux-mm peanut gallery
(unless the linux-ext4 list got removed from the cc list, or some such).

I haven't had time to take a close look at the ext4 changes, and I'll
try to carve out some time to do that --- but has anyone from the mm
side of the world taken a look at these patches?

Thanks,

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
