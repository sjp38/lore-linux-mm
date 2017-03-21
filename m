Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C8C336B03A0
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 15:22:45 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id f84so70034576ioj.6
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 12:22:45 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0117.outbound.protection.outlook.com. [104.47.1.117])
        by mx.google.com with ESMTPS id k93si22115111iod.100.2017.03.21.12.22.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 Mar 2017 12:22:44 -0700 (PDT)
Subject: Re: [PATCHv2] x86/mm: set x32 syscall bit in SET_PERSONALITY()
References: <20170321163712.20334-1-dsafonov@virtuozzo.com>
 <20170321171723.GB21564@uranus.lan>
 <CALCETrXoxRBTon8+jrYcbruYVUZASwgd-kzH-A96DGvT7gLXVA@mail.gmail.com>
 <6648805c-e0d8-5e27-9e19-602ab47937a7@virtuozzo.com>
 <20170321184058.GD21564@uranus.lan>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <dfdb16d4-aa6e-8635-1ea5-f6ac57b1dd05@virtuozzo.com>
Date: Tue, 21 Mar 2017 22:19:01 +0300
MIME-Version: 1.0
In-Reply-To: <20170321184058.GD21564@uranus.lan>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Adam Borowski <kilobyte@angband.pl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrei Vagin <avagin@gmail.com>, Borislav Petkov <bp@suse.de>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, X86 ML <x86@kernel.org>, "H.
 Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On 03/21/2017 09:40 PM, Cyrill Gorcunov wrote:
> On Tue, Mar 21, 2017 at 09:09:40PM +0300, Dmitry Safonov wrote:
>>
>> I guess the question comes from that we're releasing CRIU 3.0 with
>> 32-bit C/R and some other cool stuff, but we don't support x32 yet.
>> As we don't want release a thing that we aren't properly testing.
>> So for a while we should error on dumping x32 applications.
>
> yes
>
>> I think, the best way for now is to check physicall address of vdso
>> from /proc/.../pagemap. If it's CONFIG_VDSO=n kernel, I guess we could
>> also add check for %ds from ptrace's register set. For x32 it's set to
>> __USER_DS, while for native it's 0 (looking at start_thread() and
>> compat_start_thread()). The application can simply change it without
>> any consequence - so it's not very reliable, we could only warn at
>> catching it, not rely on this.
>
> indeed, thanks!

Also, even more simple-minded: for now we could just check binary magic
from /proc/.../exe, for now stopping on x32 binaries.

-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
