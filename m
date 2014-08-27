Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 43E2C6B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 16:06:16 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so1143604pad.11
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 13:06:15 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cz3si2621304pdb.38.2014.08.27.13.06.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Aug 2014 13:06:14 -0700 (PDT)
Date: Wed, 27 Aug 2014 13:06:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 00/21] Support ext4 on NV-DIMMs
Message-Id: <20140827130613.c8f6790093d279a447196f17@linux-foundation.org>
In-Reply-To: <cover.1409110741.git.matthew.r.wilcox@intel.com>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Tue, 26 Aug 2014 23:45:20 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:

> One of the primary uses for NV-DIMMs is to expose them as a block device
> and use a filesystem to store files on the NV-DIMM.  While that works,
> it currently wastes memory and CPU time buffering the files in the page
> cache.  We have support in ext2 for bypassing the page cache, but it
> has some races which are unfixable in the current design.  This series
> of patches rewrite the underlying support, and add support for direct
> access to ext4.

Sat down to read all this but I'm finding it rather unwieldy - it's
just a great blob of code.  Is there some overall
what-it-does-and-how-it-does-it roadmap?

Some explanation of why one would use ext4 instead of, say,
suitably-modified ramfs/tmpfs/rd/etc?

Performance testing results?

Carsten Otte wrote filemap_xip.c and may be a useful reviewer of this
work.

All the patch subjects violate Documentation/SubmittingPatches
section 15 ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
