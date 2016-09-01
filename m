Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 483EB6B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 02:18:52 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u81so53705644wmu.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 23:18:52 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id gz2si4084132wjc.141.2016.08.31.23.18.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 23:18:50 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id i138so10986454wmf.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 23:18:50 -0700 (PDT)
Date: Thu, 1 Sep 2016 08:18:46 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv4 0/6] x86: 32-bit compatible C/R on x86_64
Message-ID: <20160901061846.GA22552@gmail.com>
References: <20160831135936.2281-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160831135936.2281-1-dsafonov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, tglx@linutronix.de, hpa@zytor.com, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, gorcunov@openvz.org, xemul@virtuozzo.com


* Dmitry Safonov <dsafonov@virtuozzo.com> wrote:

> Changes from v3:
> - proper ifdefs around vdso_image_32
> - missed Reviewed-by tag

>  arch/x86/entry/vdso/vma.c         | 81 +++++++++++++++++++++++++++------------
>  arch/x86/ia32/ia32_signal.c       |  2 +-
>  arch/x86/include/asm/compat.h     |  8 ++--
>  arch/x86/include/asm/fpu/signal.h |  6 +++
>  arch/x86/include/asm/signal.h     |  4 ++
>  arch/x86/include/asm/vdso.h       |  2 +
>  arch/x86/include/uapi/asm/prctl.h |  6 +++
>  arch/x86/kernel/process_64.c      | 25 ++++++++++++
>  arch/x86/kernel/ptrace.c          |  2 +-
>  arch/x86/kernel/signal.c          | 20 +++++-----
>  arch/x86/kernel/signal_compat.c   | 34 ++++++++++++++--
>  fs/binfmt_elf.c                   | 23 ++++-------
>  kernel/signal.c                   |  7 ++++
>  13 files changed, 162 insertions(+), 58 deletions(-)

Ok, this series looks good to me - does anyone have any objections?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
