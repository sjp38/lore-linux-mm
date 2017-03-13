Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 823AF6B038A
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 05:40:11 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u48so42902494wrc.0
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 02:40:11 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id t129si8283576wmb.163.2017.03.13.02.40.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 02:40:10 -0700 (PDT)
Date: Mon, 13 Mar 2017 10:39:57 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv6 4/5] x86/mm: check in_compat_syscall() instead TIF_ADDR32
 for mmap(MAP_32BIT)
In-Reply-To: <20170306141721.9188-5-dsafonov@virtuozzo.com>
Message-ID: <alpine.DEB.2.20.1703131035020.3558@nanos>
References: <20170306141721.9188-1-dsafonov@virtuozzo.com> <20170306141721.9188-5-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, 6 Mar 2017, Dmitry Safonov wrote:

> Result of mmap() calls with MAP_32BIT flag at this moment depends
> on thread flag TIF_ADDR32, which is set during exec() for 32-bit apps.
> It's broken as the behavior of mmap() shouldn't depend on exec-ed
> application's bitness. Instead, it should check the bitness of mmap()
> syscall.
> How it worked before:
> o for 32-bit compatible binaries it is completely ignored. Which was
> fine when there were one mmap_base, computed for 32-bit syscalls.
> After introducing mmap_compat_base 64-bit syscalls do use computed
> for 64-bit syscalls mmap_base, which means that we can allocate 64-bit
> address with 64-bit syscall in application launched from 32-bit
> compatible binary. And ignoring this flag is not expected behavior.

Well, the real question here is, whether we should allow 32bit applications
to obtain 64bit mappings at all. We can very well force 32bit applications
into the 4GB address space as it was before your mmap base splitup and be
done with it.

Thanks,

	tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
