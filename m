Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4084A6B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 18:15:15 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 51so1708503uai.3
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 15:15:15 -0800 (PST)
Received: from mail-vk0-x22e.google.com (mail-vk0-x22e.google.com. [2607:f8b0:400c:c05::22e])
        by mx.google.com with ESMTPS id h94si7708373uad.233.2016.12.08.15.15.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 15:15:14 -0800 (PST)
Received: by mail-vk0-x22e.google.com with SMTP id w194so617951vkw.2
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 15:15:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161123181330.10705-1-dsafonov@virtuozzo.com>
References: <20161123181330.10705-1-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 8 Dec 2016 15:14:53 -0800
Message-ID: <CALCETrUQDBX_QqHGeozQ3Q+9pF3SeyE9XyPqX4M6k3XOV8Zd=Q@mail.gmail.com>
Subject: Re: [PATCH] x86/coredump: always use user_regs_struct for compat_elf_gregset_t
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Dmitry Safonov <0x7f454c46@gmail.com>, Ingo Molnar <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>

On Nov 23, 2016 10:16 AM, "Dmitry Safonov" <dsafonov@virtuozzo.com> wrote:
>
> From commit 90954e7b9407 ("x86/coredump: Use pr_reg size, rather that
> TIF_IA32 flag") elf coredump file is constructed according to register
> set size - and that's good: if binary crashes with 32-bit code selector,
> generate 32-bit ELF core, otherwise - 64-bit core.
> That was made for restoring 32-bit applications on x86_64: we want
> 32-bit application after restore to generate 32-bit ELF dump on crash.
> All was quite good and recently I started reworking 32-bit applications
> dumping part of CRIU: now it has two parasites (32 and 64) for seizing
> compat/native tasks, after rework it'll have one parasite, working in
> 64-bit mode, to which 32-bit prologue long-jumps during infection.
>
> And while it has worked for my work machine, in VM with
> !CONFIG_X86_X32_ABI during reworking I faced that segfault in 32-bit
> binary, that has long-jumped to 64-bit mode results in dereference
> of garbage:

Can you point to the actual line that's crashing?  I'm wondering if we
have code that should be made more robust.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
