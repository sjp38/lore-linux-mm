Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8EFE96B0396
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 14:41:01 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id v2so93351698lfi.2
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 11:41:01 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id q132si11793805lfe.183.2017.03.21.11.40.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 11:41:00 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id v2so13956058lfi.2
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 11:40:59 -0700 (PDT)
Date: Tue, 21 Mar 2017 21:40:58 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCHv2] x86/mm: set x32 syscall bit in SET_PERSONALITY()
Message-ID: <20170321184058.GD21564@uranus.lan>
References: <20170321163712.20334-1-dsafonov@virtuozzo.com>
 <20170321171723.GB21564@uranus.lan>
 <CALCETrXoxRBTon8+jrYcbruYVUZASwgd-kzH-A96DGvT7gLXVA@mail.gmail.com>
 <6648805c-e0d8-5e27-9e19-602ab47937a7@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6648805c-e0d8-5e27-9e19-602ab47937a7@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: Andy Lutomirski <luto@amacapital.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Adam Borowski <kilobyte@angband.pl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrei Vagin <avagin@gmail.com>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Mar 21, 2017 at 09:09:40PM +0300, Dmitry Safonov wrote:
> 
> I guess the question comes from that we're releasing CRIU 3.0 with
> 32-bit C/R and some other cool stuff, but we don't support x32 yet.
> As we don't want release a thing that we aren't properly testing.
> So for a while we should error on dumping x32 applications.

yes

> I think, the best way for now is to check physicall address of vdso
> from /proc/.../pagemap. If it's CONFIG_VDSO=n kernel, I guess we could
> also add check for %ds from ptrace's register set. For x32 it's set to
> __USER_DS, while for native it's 0 (looking at start_thread() and
> compat_start_thread()). The application can simply change it without
> any consequence - so it's not very reliable, we could only warn at
> catching it, not rely on this.

indeed, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
