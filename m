Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id A83816B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 07:27:45 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u3so1692442wey.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 04:27:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350665289-7288-1-git-send-email-andi@firstfloor.org>
References: <1350665289-7288-1-git-send-email-andi@firstfloor.org>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Mon, 22 Oct 2012 13:27:23 +0200
Message-ID: <CAHO5Pa0W-WGBaPvzdRJxYPdrg-K9guChswo3KJheK4BaRzsRwQ@mail.gmail.com>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v6
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Hillf Danton <dhillf@gmail.com>

Andi,

> +#define MAP_HUGE_2MB    (21 << MAP_HUGE_SHIFT)
> +#define MAP_HUGE_1GB    (30 << MAP_HUGE_SHIFT)
> +#define SHM_HUGE_SHIFT  26
> +#define SHM_HUGE_MASK   0x3f
> +#define SHM_HUGE_2MB    (21 << SHM_HUGE_SHIFT)
> +#define SHM_HUGE_1GB    (30 << SHM_HUGE_SHIFT)

Maybe I am missing something obvious, but does this not conflict with
include/uapi/asm-generic/mman-common.h:

#ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
# define MAP_UNINITIALIZED 0x4000000
...

0x4000000 == (1 << 26)
?

Thanks,

Michael

-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
