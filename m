Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA8282F64
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 16:48:47 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id e7so105371669lfe.0
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 13:48:47 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id s192si16109460lfe.215.2016.08.29.13.48.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 13:48:45 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id 33so7481177lfw.3
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 13:48:45 -0700 (PDT)
Date: Mon, 29 Aug 2016 23:48:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 RESEND 0/2] Align mmap address for DAX pmd mappings
Message-ID: <20160829204842.GA27286@node.shutemov.name>
References: <1472497881-9323-1-git-send-email-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1472497881-9323-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com, david@fromorbit.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, mike.kravetz@oracle.com, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hughd@google.com

On Mon, Aug 29, 2016 at 01:11:19PM -0600, Toshi Kani wrote:
> When CONFIG_FS_DAX_PMD is set, DAX supports mmap() using pmd page
> size.  This feature relies on both mmap virtual address and FS
> block (i.e. physical address) to be aligned by the pmd page size.
> Users can use mkfs options to specify FS to align block allocations.
> However, aligning mmap address requires code changes to existing
> applications for providing a pmd-aligned address to mmap().
> 
> For instance, fio with "ioengine=mmap" performs I/Os with mmap() [1].
> It calls mmap() with a NULL address, which needs to be changed to
> provide a pmd-aligned address for testing with DAX pmd mappings.
> Changing all applications that call mmap() with NULL is undesirable.
> 
> This patch-set extends filesystems to align an mmap address for
> a DAX file so that unmodified applications can use DAX pmd mappings.

+Hugh

Can we get it used for shmem/tmpfs too?
I don't think we should duplicate essentially the same functionality in
multiple places.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
