Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id A51566B007E
	for <linux-mm@kvack.org>; Sat,  2 Apr 2016 18:05:32 -0400 (EDT)
Received: by mail-lf0-f53.google.com with SMTP id p188so91203218lfd.0
        for <linux-mm@kvack.org>; Sat, 02 Apr 2016 15:05:32 -0700 (PDT)
Received: from mail-lb0-x22f.google.com (mail-lb0-x22f.google.com. [2a00:1450:4010:c04::22f])
        by mx.google.com with ESMTPS id zd3si11634419lbb.93.2016.04.02.15.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Apr 2016 15:05:31 -0700 (PDT)
Received: by mail-lb0-x22f.google.com with SMTP id bc4so108319264lbc.2
        for <linux-mm@kvack.org>; Sat, 02 Apr 2016 15:05:31 -0700 (PDT)
Date: Sun, 3 Apr 2016 01:05:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/huge_memory: replace VM_NO_THP VM_BUG_ON with actual
 VMA check
Message-ID: <20160402220528.GA7977@node.shutemov.name>
References: <145961146490.28194.16019687861681349309.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <145961146490.28194.16019687861681349309.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, stable <stable@vger.kernel.org>

On Sat, Apr 02, 2016 at 06:37:44PM +0300, Konstantin Khlebnikov wrote:
> Khugepaged detects own VMAs by checking vm_file and vm_ops but this
> way it cannot distinguish private /dev/zero mappings from other special
> mappings like /dev/hpet which has no vm_ops and popultes PTEs in mmap.
> 
> This fixes false-positive VM_BUG_ON and prevents installing THP where
> they are not expected.
> 
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Link: http://lkml.kernel.org/r/CACT4Y+ZmuZMV5CjSFOeXviwQdABAgT7T+StKfTqan9YDtgEi5g@mail.gmail.com
> Fixes: 78f11a255749 ("mm: thp: fix /dev/zero MAP_PRIVATE and vm_flags cleanups")
> Cc: stable <stable@vger.kernel.org>

Looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
