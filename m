Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 891316B027A
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 18:26:15 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id b35so39232099uaa.1
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 15:26:15 -0700 (PDT)
Received: from mail-vk0-x22c.google.com (mail-vk0-x22c.google.com. [2607:f8b0:400c:c05::22c])
        by mx.google.com with ESMTPS id h201si1167190vkd.78.2016.10.27.15.26.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 15:26:14 -0700 (PDT)
Received: by mail-vk0-x22c.google.com with SMTP id y123so40974446vka.3
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 15:26:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161027141516.28447-3-dsafonov@virtuozzo.com>
References: <20161027141516.28447-1-dsafonov@virtuozzo.com> <20161027141516.28447-3-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 27 Oct 2016 15:25:53 -0700
Message-ID: <CALCETrW=qxgd3UpimGFCjHLVb1sgRjqOE1KNps=CT4cmVo7B_w@mail.gmail.com>
Subject: Re: [PATCH 2/2] x86/vdso: set vdso pointer only after success
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Andy Lutomirski <luto@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Thu, Oct 27, 2016 at 7:15 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> Those pointers were initialized before call to _install_special_mapping
> after the commit f7b6eb3fa072 ("x86: Set context.vdso before installing
> the mapping"). This is not required anymore as special mappings have
> their vma name and don't use arch_vma_name() after commit a62c34bd2a8a
> ("x86, mm: Improve _install_special_mapping and fix x86 vdso naming").
> So, this way to init looks less entangled.
> I even belive, we can remove null initializers:
> - on failure load_elf_binary() will not start a new thread;
> - arch_prctl will have the same pointers as before syscall.

Acked-by: Andy Lutomirski <luto@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
