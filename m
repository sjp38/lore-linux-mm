Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id CE931440313
	for <linux-mm@kvack.org>; Sun,  4 Oct 2015 22:04:22 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so94223779wic.0
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 19:04:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id he6si28099983wjc.75.2015.10.04.19.04.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 04 Oct 2015 19:04:21 -0700 (PDT)
Date: Sun, 4 Oct 2015 19:04:06 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH 3/3] mm/nommu: drop unlikely behind BUG_ON()
Message-ID: <20151005020406.GB8831@linux-uzut.site>
References: <cf38aa69e23adb31ebb4c9d80384dabe9b91b75e.1443937856.git.geliangtang@163.com>
 <a89c7bef0699c3d3f5e592c58ff3f0a4db482b69.1443937856.git.geliangtang@163.com>
 <45bf632d263280847a2a894017c62b7f2a71eda1.1443937856.git.geliangtang@163.com>
 <CALq1K=JTWq+p0M+45nKm4yMs06k=Mt3y7+hbv6Usx+eX+=2MLQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CALq1K=JTWq+p0M+45nKm4yMs06k=Mt3y7+hbv6Usx+eX+=2MLQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Romanovsky <leon@leon.nu>
Cc: Geliang Tang <geliangtang@163.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, 04 Oct 2015, Leon Romanovsky wrote:

>On Sun, Oct 4, 2015 at 9:18 AM, Geliang Tang <geliangtang@163.com> wrote:
>> BUG_ON() already contain an unlikely compiler flag. Drop it.
>It is not the case if CONFIG_BUG and HAVE_ARCH_BUG_ON are not set.

Yeah, but that's like the 1% of the cases -- and those probably don't even care
about the branch prediction (I could be wrong). So overall I like getting rid of
explicit BUG_ON(unlikely(... calls. In fact there's a _reason_ why there are so
few of them in the kernel.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
