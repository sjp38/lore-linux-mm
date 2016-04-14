Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 328EC6B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 13:39:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c20so141056287pfc.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:39:33 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id vx8si10640964pac.107.2016.04.14.10.39.32
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 10:39:32 -0700 (PDT)
Date: Thu, 14 Apr 2016 13:39:22 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH 09/10] huge pagecache: mmap_sem is unlocked when
 truncation splits pmd
Message-ID: <20160414173922.GE3120@linux.intel.com>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
 <alpine.LSU.2.11.1604051352540.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1604051352540.5965@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Apr 05, 2016 at 01:55:23PM -0700, Hugh Dickins wrote:
> zap_pmd_range()'s CONFIG_DEBUG_VM !rwsem_is_locked(&mmap_sem) BUG()
> will be invalid with huge pagecache, in whatever way it is implemented:
> truncation of a hugely-mapped file to an unhugely-aligned size would
> easily hit it.

We can reproduce this BUG() in the current Linus tree with DAX PMDs.
Andrew, can you send this patch to Linus for inclusion in 4.7?

Tested-by: Matthew Wilcox <willy@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
