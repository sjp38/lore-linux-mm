Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF556B0253
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 15:27:22 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id x75so90652357vke.5
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 12:27:22 -0800 (PST)
Received: from mail-ua0-x230.google.com (mail-ua0-x230.google.com. [2607:f8b0:400c:c08::230])
        by mx.google.com with ESMTPS id l19si6281125uaf.155.2017.01.17.12.27.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 12:27:21 -0800 (PST)
Received: by mail-ua0-x230.google.com with SMTP id 35so111677758uak.1
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 12:27:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170116123310.22697-3-dsafonov@virtuozzo.com>
References: <20170116123310.22697-1-dsafonov@virtuozzo.com> <20170116123310.22697-3-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 17 Jan 2017 12:27:00 -0800
Message-ID: <CALCETrUHLpsrB0M3rkrxw8R=6Dto5gFz+enP=W3C6WPDTa36GA@mail.gmail.com>
Subject: Re: [PATCHv2 2/5] x86/mm: introduce mmap_{,legacy}_base
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, X86 ML <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jan 16, 2017 at 4:33 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> In the following patch they will be used to compute:
> - mmap_base in compat sys_mmap() in native 64-bit binary
> and vice-versa
> - mmap_base for native sys_mmap() in compat x32/ia32-bit binary.

I may be wrong here, but I suspect that you're repeating something
that I consider to be a mistake that's all over the x86 code.
Specifically, you're distinguishing "native" from "compat" instead of
"32-bit" from "64-bit".  If you did the latter, then you wouldn't need
the "native" case to work differently on 32-bit kernels vs 64-bit
kernels, I think.  Would making this change make your code simpler?

The x86 signal code is the worst offender IMO.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
