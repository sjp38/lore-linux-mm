Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id EC3A06B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 08:06:32 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so8351918pab.37
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 05:06:32 -0800 (PST)
Received: from psmtp.com ([74.125.245.190])
        by mx.google.com with SMTP id ku6si14198591pbc.156.2013.11.20.05.06.30
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 05:06:31 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CANaxB-xcyRBB4UV+RMxh34=eDCuCfDUFEHexvkSCsg4fKDDGRQ@mail.gmail.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1381428359-14843-35-git-send-email-kirill.shutemov@linux.intel.com>
 <CANaxB-x3k8DPEaDCtCzhkuyPcwR1YcRJZwXW777+q+y2KBvzHg@mail.gmail.com>
 <20131120125325.07A42E0090@blue.fi.intel.com>
 <CANaxB-xcyRBB4UV+RMxh34=eDCuCfDUFEHexvkSCsg4fKDDGRQ@mail.gmail.com>
Subject: Re: [PATCH 34/34] mm: dynamically allocate page->ptl if it cannot be
 embedded to struct page
Content-Transfer-Encoding: 7bit
Message-Id: <20131120130626.715B7E0090@blue.fi.intel.com>
Date: Wed, 20 Nov 2013 15:06:26 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Wagin <avagin@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org

Andrey Wagin wrote:
> 2013/11/20 Kirill A. Shutemov <kirill.shutemov@linux.intel.com>:
> > Andrey Wagin wrote:
> >> Hi Kirill,
> >>
> >> Looks like this patch adds memory leaks.
> >> [  116.188310] kmemleak: 15672 new suspected memory leaks (see
> >> /sys/kernel/debug/kmemleak)
> >> unreferenced object 0xffff8800da45a350 (size 96):
> >>   comm "dracut-initqueu", pid 93, jiffies 4294671391 (age 362.277s)
> >>   hex dump (first 32 bytes):
> >>     07 00 07 00 ad 4e ad de ff ff ff ff 6b 6b 6b 6b  .....N......kkkk
> >>     ff ff ff ff ff ff ff ff 80 24 b4 82 ff ff ff ff  .........$......
> >>   backtrace:
> >>     [<ffffffff817152fe>] kmemleak_alloc+0x5e/0xc0
> >>     [<ffffffff811c34f3>] kmem_cache_alloc_trace+0x113/0x290
> >>     [<ffffffff811920f7>] __ptlock_alloc+0x27/0x50
> >>     [<ffffffff81192849>] __pmd_alloc+0x59/0x170
> >>     [<ffffffff81195ffa>] copy_page_range+0x38a/0x3e0
> >>     [<ffffffff8105a013>] dup_mm+0x313/0x540
> >>     [<ffffffff8105b9da>] copy_process+0x161a/0x1880
> >>     [<ffffffff8105c01b>] do_fork+0x8b/0x360
> >>     [<ffffffff8105c306>] SyS_clone+0x16/0x20
> >>     [<ffffffff81727b79>] stub_clone+0x69/0x90
> >>     [<ffffffffffffffff>] 0xffffffffffffffff
> >>
> >> It's quite serious, because my test host went to panic in a few hours.
> >
> > Sorry for that.
> >
> > Could you test patch below.
> 
> Yes, it works.
> 
> I found this too a few minutes ago:)

Nice

Tested-by ?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
