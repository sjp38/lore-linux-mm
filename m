Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 088D46B0279
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 17:45:43 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 12so2134649wmn.1
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 14:45:42 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k33si13169047wre.240.2017.06.26.14.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 14:45:41 -0700 (PDT)
Date: Mon, 26 Jun 2017 14:45:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [kees:for-next/fortify 8/8] include/linux/string.h:309:4:
 error: call to '__read_overflow2' declared with attribute error: detected
 read beyond size of object passed as 2nd parameter
Message-Id: <20170626144539.1e2f7e07ed9d7063db77d063@linux-foundation.org>
In-Reply-To: <201706250930.6iL2L5TJ%fengguang.wu@intel.com>
References: <201706250930.6iL2L5TJ%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Daniel Micay <danielmicay@gmail.com>, kbuild-all@01.org, Kees Cook <keescook@chromium.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sun, 25 Jun 2017 09:16:32 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git for-next/fortify
> head:   d481d95b725d2abc7ed31f2f8c4c95c2bd8b0282
> commit: d481d95b725d2abc7ed31f2f8c4c95c2bd8b0282 [8/8] include/linux/string.h: add the option of fortified string.h functions
> config: i386-allmodconfig (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         git checkout d481d95b725d2abc7ed31f2f8c4c95c2bd8b0282
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>    In file included from arch/x86/include/asm/page_32.h:34:0,
>                     from arch/x86/include/asm/page.h:13,
>                     from arch/x86/include/asm/thread_info.h:11,
>                     from include/linux/thread_info.h:37,
>                     from arch/x86/include/asm/preempt.h:6,
>                     from include/linux/preempt.h:80,
>                     from include/linux/spinlock.h:50,
>                     from include/linux/mmzone.h:7,
>                     from include/linux/gfp.h:5,
>                     from include/linux/slab.h:14,
>                     from drivers/scsi/csiostor/csio_lnode.c:37:
>    In function 'memcpy',
>        inlined from 'csio_append_attrib' at drivers/scsi/csiostor/csio_lnode.c:248:2,

hm, this was added by Kees's 42c335f7e6702 ("scsi: csiostor: Avoid
content leaks and casts").

I think I'll tend to ignore these odd stragglers now - a few more will
probably pop up and we can fix them after 4.13-rc1 as they are
reported.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
