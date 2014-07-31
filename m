Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id C51CD6B0035
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 21:20:33 -0400 (EDT)
Received: by mail-vc0-f181.google.com with SMTP id lf12so3207558vcb.12
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 18:20:33 -0700 (PDT)
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
        by mx.google.com with ESMTPS id z17si3291456vct.60.2014.07.30.18.20.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Jul 2014 18:20:33 -0700 (PDT)
Received: by mail-vc0-f170.google.com with SMTP id lf12so3214428vcb.1
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 18:20:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1407301727300.12181@chino.kir.corp.google.com>
References: <53d98399.wRC4T5IRh+/QWqVO%fengguang.wu@intel.com>
	<alpine.DEB.2.02.1407301727300.12181@chino.kir.corp.google.com>
Date: Wed, 30 Jul 2014 18:20:32 -0700
Message-ID: <CAOesGMgFeg_HNJMfxSzso1e48L+nFPCMqXZAAYKhV02Z29jQBg@mail.gmail.com>
Subject: Re: [patch] kexec: export free_huge_page to VMCOREINFO fix
From: Olof Johansson <olof@lixom.net>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, kbuild test robot <fengguang.wu@intel.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Jul 30, 2014 at 5:30 PM, David Rientjes <rientjes@google.com> wrote:
> free_huge_page() is undefined without CONFIG_HUGETLBFS and there's no need
> to filter PageHuge() page is such a configuration either.
>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Yup, broke a bunch of configs on mainline on my ARM builder too.

Acked-by: Olof Johansson <olof@lixom.net>

>  To be folded into kexec-export-free_huge_page-to-vmcoreinfo.patch.

Looks to be a bit late for that, Linus just merged it. Will need to go
in as-is instead.


-Olof

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
