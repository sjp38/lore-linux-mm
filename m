Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 425FF6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 22:25:39 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so4772953pad.1
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 19:25:39 -0800 (PST)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2on0110.outbound.protection.outlook.com. [207.46.100.110])
        by mx.google.com with ESMTPS id be6si255168pbd.160.2015.01.22.19.25.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 22 Jan 2015 19:25:38 -0800 (PST)
Date: Thu, 22 Jan 2015 21:20:17 -0600
From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: [PATCH 2/2] mm: fix undefined reference to `.kernel_map_pages'
 on PPC builds
Message-ID: <20150122212017.4b7032d52a6c75c06d5b4728@freescale.com>
In-Reply-To: <CAC5umyiF52cykH2_5TD0yzXb+842gywpe-+XZHEwmrDe0nYCPw@mail.gmail.com>
References: <20150120140200.aa7ba0eb28d95e456972e178@freescale.com>
	<20150120230150.GA14475@cloud>
	<20150120160738.edfe64806cc8b943beb1dfa0@linux-foundation.org>
	<CAC5umyieZn7ppXkKb45O=C=BF+iv6R_A1Dwfhro=cBJzFeovrA@mail.gmail.com>
	<20150122014550.GA21444@js1304-P5Q-DELUXE>
	<20150122144147.019eedc41f189eac44c3c4cd@freescale.com>
	<CAC5umyiF52cykH2_5TD0yzXb+842gywpe-+XZHEwmrDe0nYCPw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, josh@joshtriplett.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Al Viro <viro@zeniv.linux.org.uk>, Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Jens Axboe <axboe@fb.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Fri, 23 Jan 2015 08:49:36 +0900
Akinobu Mita <akinobu.mita@gmail.com> wrote:

> 2015-01-23 5:41 GMT+09:00 Kim Phillips <kim.phillips@freescale.com>:
> > Thanks. Now I get this:
> >
> >   LD      init/built-in.o
> > mm/built-in.o: In function `kernel_map_pages':
> > include/linux/mm.h:2076: undefined reference to `.__kernel_map_pages'
> > include/linux/mm.h:2076: undefined reference to `.__kernel_map_pages'
> > include/linux/mm.h:2076: undefined reference to `.__kernel_map_pages'
> > Makefile:925: recipe for target 'vmlinux' failed
> > make: *** [vmlinux] Error 1
> >
> > but, AFAICT, that's not because this patch is invalid: it's because
> > __kernel_map_pages() isn't implemented in
> > arch/powerpc/mm/pgtable_64.c, i.e., for non-PPC_STD_MMU_64 PPC64
> > machines.
> 
> Then, in order to use generic __kernel_map_pages() in mm/debug-pagealloc.c,
> CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC shouldn't be selected in
> arch/powerpc/Kconfig, when CONFIG_PPC_STD_MMU_64 isn't defined.

Thanks.  I'm still build-testing this now:
