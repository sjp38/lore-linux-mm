Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD7B6B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 04:02:05 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z36so18998527wrb.13
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 01:02:04 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id x21si6445836wma.169.2017.07.25.01.02.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 01:02:04 -0700 (PDT)
Date: Tue, 25 Jul 2017 10:01:58 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v5 1/5] mm: add vm_insert_mixed_mkwrite()
Message-ID: <20170725080158.GA5374@lst.de>
References: <20170724170616.25810-1-ross.zwisler@linux.intel.com> <20170724170616.25810-2-ross.zwisler@linux.intel.com> <20170724221400.pcq5zvke7w2yfkxi@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724221400.pcq5zvke7w2yfkxi@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Tue, Jul 25, 2017 at 01:14:00AM +0300, Kirill A. Shutemov wrote:
> I guess it's up to filesystem if it wants to reuse the same spot to write
> data or not. I think your assumptions works for ext4 and xfs. I wouldn't
> be that sure for btrfs or other filesystems with CoW support.

Or XFS with reflinks for that matter.  Which currently can't be
combined with DAX, but I had a somewhat working version a few month
ago.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
