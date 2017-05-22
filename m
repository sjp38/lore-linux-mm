Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 67DD3831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 07:42:47 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 204so24786658wmy.1
        for <linux-mm@kvack.org>; Mon, 22 May 2017 04:42:47 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 197si19955097wmp.127.2017.05.22.04.42.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 04:42:46 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id k15so31474342wmh.3
        for <linux-mm@kvack.org>; Mon, 22 May 2017 04:42:45 -0700 (PDT)
Date: Mon, 22 May 2017 14:42:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
Message-ID: <20170522114243.2wrdbncilozygbpl@node.shutemov.name>
References: <1495433562-26625-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1495433562-26625-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Mon, May 22, 2017 at 09:12:42AM +0300, Mike Rapoport wrote:
> Currently applications can explicitly enable or disable THP for a memory
> region using MADV_HUGEPAGE or MADV_NOHUGEPAGE. However, once either of
> these advises is used, the region will always have
> VM_HUGEPAGE/VM_NOHUGEPAGE flag set in vma->vm_flags.
> The MADV_CLR_HUGEPAGE resets both these flags and allows managing THP in
> the region according to system-wide settings.

Seems reasonable. But could you describe an use-case when it's useful in
real world.

And the name is bad. But I don't have better suggestion. At least do not
abbreviate CLEAR. Saving two letters doesn't worth it.

Maybe RESET instead?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
