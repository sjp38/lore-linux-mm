Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A237D6B0038
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 10:51:37 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 2so49178wmp.21
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 07:51:37 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 8si3759943wmc.94.2017.03.31.07.51.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 31 Mar 2017 07:51:36 -0700 (PDT)
Date: Fri, 31 Mar 2017 16:51:25 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv5] x86/mm: make in_compat_syscall() work during exec
In-Reply-To: <20170331111137.28170-1-dsafonov@virtuozzo.com>
Message-ID: <alpine.DEB.2.20.1703311650220.1780@nanos>
References: <20170331111137.28170-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Adam Borowski <kilobyte@angband.pl>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Andrei Vagin <avagin@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>

On Fri, 31 Mar 2017, Dmitry Safonov wrote:
>  #include <asm/intel_rdt.h>
> +#include <asm/unistd_64.h>
> +#ifdef CONFIG_X86_X32
> +#include <asm/unistd_64_x32.h>
> +#endif

Bah. asm/unistd.h includes both 64bit and x32 headers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
