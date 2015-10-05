Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2CD79440321
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 03:53:27 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so107629806wic.0
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 00:53:26 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id gz7si14909808wib.35.2015.10.05.00.53.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Oct 2015 00:53:25 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so106647144wic.1
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 00:53:25 -0700 (PDT)
Date: Mon, 5 Oct 2015 10:49:19 +0300
From: Leon Romanovsky <leon@leon.nu>
Subject: Re: [PATCH 3/3] mm/nommu: drop unlikely behind BUG_ON()
Message-ID: <20151005074919.GA10359@leon.nu>
References: <cf38aa69e23adb31ebb4c9d80384dabe9b91b75e.1443937856.git.geliangtang@163.com>
 <a89c7bef0699c3d3f5e592c58ff3f0a4db482b69.1443937856.git.geliangtang@163.com>
 <45bf632d263280847a2a894017c62b7f2a71eda1.1443937856.git.geliangtang@163.com>
 <CALq1K=JTWq+p0M+45nKm4yMs06k=Mt3y7+hbv6Usx+eX+=2MLQ@mail.gmail.com>
 <20151005020406.GB8831@linux-uzut.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151005020406.GB8831@linux-uzut.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, Oct 04, 2015 at 07:04:06PM -0700, Davidlohr Bueso wrote:
> On Sun, 04 Oct 2015, Leon Romanovsky wrote:
> 
> >On Sun, Oct 4, 2015 at 9:18 AM, Geliang Tang <geliangtang@163.com> wrote:
> >>BUG_ON() already contain an unlikely compiler flag. Drop it.
> >It is not the case if CONFIG_BUG and HAVE_ARCH_BUG_ON are not set.
> 
> Yeah, but that's like the 1% of the cases -- and those probably don't even care
> about the branch prediction (I could be wrong). So overall I like getting rid of
> explicit BUG_ON(unlikely(... calls. In fact there's a _reason_ why there are so
> few of them in the kernel.
I agree with you that this change is welcomed and I would like to see it
is accepted.

My main concern that I would expect to see it's coming after the change
of BUG_ON definition to be similar in all places, with "unlikely" in all
definitions, and not instead.

> 
> Thanks,
> Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
