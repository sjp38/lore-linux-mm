Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C528C6B039A
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 14:51:25 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g2so348402372pge.7
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 11:51:25 -0700 (PDT)
Received: from mail.zytor.com ([2001:1868:a000:17::138])
        by mx.google.com with ESMTPS id l13si8306527pgc.255.2017.03.21.11.51.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 11:51:25 -0700 (PDT)
Date: Tue, 21 Mar 2017 11:51:09 -0700
In-Reply-To: <20170321184058.GD21564@uranus.lan>
References: <20170321163712.20334-1-dsafonov@virtuozzo.com> <20170321171723.GB21564@uranus.lan> <CALCETrXoxRBTon8+jrYcbruYVUZASwgd-kzH-A96DGvT7gLXVA@mail.gmail.com> <6648805c-e0d8-5e27-9e19-602ab47937a7@virtuozzo.com> <20170321184058.GD21564@uranus.lan>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCHv2] x86/mm: set x32 syscall bit in SET_PERSONALITY()
From: hpa@zytor.com
Message-ID: <A4AEF765-7F0E-47AE-B08F-3B8D13FA4EAD@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: Andy Lutomirski <luto@amacapital.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Adam Borowski <kilobyte@angband.pl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrei Vagin <avagin@gmail.com>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, X86 ML <x86@kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On March 21, 2017 11:40:58 AM PDT, Cyrill Gorcunov <gorcunov@gmail=2Ecom> w=
rote:
>On Tue, Mar 21, 2017 at 09:09:40PM +0300, Dmitry Safonov wrote:
>>=20
>> I guess the question comes from that we're releasing CRIU 3=2E0 with
>> 32-bit C/R and some other cool stuff, but we don't support x32 yet=2E
>> As we don't want release a thing that we aren't properly testing=2E
>> So for a while we should error on dumping x32 applications=2E
>
>yes
>
>> I think, the best way for now is to check physicall address of vdso
>> from /proc/=2E=2E=2E/pagemap=2E If it's CONFIG_VDSO=3Dn kernel, I guess=
 we
>could
>> also add check for %ds from ptrace's register set=2E For x32 it's set
>to
>> __USER_DS, while for native it's 0 (looking at start_thread() and
>> compat_start_thread())=2E The application can simply change it without
>> any consequence - so it's not very reliable, we could only warn at
>> catching it, not rely on this=2E
>
>indeed, thanks!

I proposed to the ptrace people a virtual register for this and a few othe=
r things, but it got bikeshed to death=2E
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
