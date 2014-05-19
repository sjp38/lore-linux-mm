Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3556B0037
	for <linux-mm@kvack.org>; Mon, 19 May 2014 11:15:32 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so5891418pab.14
        for <linux-mm@kvack.org>; Mon, 19 May 2014 08:15:32 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id bi10si20014174pad.76.2014.05.19.08.15.31
        for <linux-mm@kvack.org>;
        Mon, 19 May 2014 08:15:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20140519150339.GA9300@infradead.org>
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1399387052-31660-3-git-send-email-kirill.shutemov@linux.intel.com>
 <20140519150339.GA9300@infradead.org>
Subject: Re: [PATCH 2/8] mm: kill vm_operations_struct->remap_pages
Content-Transfer-Encoding: 7bit
Message-Id: <20140519151457.72B36E009B@blue.fi.intel.com>
Date: Mon, 19 May 2014 18:14:57 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org

Christoph Hellwig wrote:
> I think this should be split into two patches and go first in the
> series:
> 
>  1) remove all instances but shmem and generic_file_vm_ops given that
>     remap_file_pages already doesn't work on anything that has a backing
>     store and all these are dead
>  2) kill the method and make the syscall call generic_file_remap_pages
>     directly as this is a core VM feature.
> 
> These two should go first because they make sense even if we can't
> actually go with the emulation yet.

Makes sense. I'll prepare patches.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
