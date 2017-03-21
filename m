Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 66DB16B039E
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 15:20:27 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c23so325182361pfj.0
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 12:20:27 -0700 (PDT)
Received: from mail.zytor.com ([2001:1868:a000:17::138])
        by mx.google.com with ESMTPS id y9si22325746pli.39.2017.03.21.12.20.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 12:20:26 -0700 (PDT)
Date: Tue, 21 Mar 2017 12:20:11 -0700
In-Reply-To: <20170321190713.GE21564@uranus.lan>
References: <20170321163712.20334-1-dsafonov@virtuozzo.com> <20170321171723.GB21564@uranus.lan> <CALCETrXoxRBTon8+jrYcbruYVUZASwgd-kzH-A96DGvT7gLXVA@mail.gmail.com> <6648805c-e0d8-5e27-9e19-602ab47937a7@virtuozzo.com> <20170321184058.GD21564@uranus.lan> <A4AEF765-7F0E-47AE-B08F-3B8D13FA4EAD@zytor.com> <20170321190713.GE21564@uranus.lan>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCHv2] x86/mm: set x32 syscall bit in SET_PERSONALITY()
From: hpa@zytor.com
Message-ID: <729D80F1-E9DC-4732-9D54-1D291188EEB6@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, Andy Lutomirski <luto@amacapital.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Adam Borowski <kilobyte@angband.pl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrei Vagin <avagin@gmail.com>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, X86 ML <x86@kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On March 21, 2017 12:07:13 PM PDT, Cyrill Gorcunov <gorcunov@gmail=2Ecom> w=
rote:
>On Tue, Mar 21, 2017 at 11:51:09AM -0700, hpa@zytor=2Ecom wrote:
>> >
>> >indeed, thanks!
>>=20
>> I proposed to the ptrace people a virtual register for this and a few
>other things, but it got bikeshed to death=2E
>
>Any mail reference left? Would like to read it=2E

Not sure=2E=2E=2E
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
