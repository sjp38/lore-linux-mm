Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1D56B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 16:06:13 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u3so3263003pfl.5
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 13:06:13 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id w3si1845812pge.245.2017.11.29.13.06.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 13:06:12 -0800 (PST)
Date: Wed, 29 Nov 2017 13:03:46 -0800
In-Reply-To: <20171129205815.GE3070@tassilo.jf.intel.com>
References: <20171110220645.59944-1-kirill.shutemov@linux.intel.com> <20171129154908.6y4st6xc7hbsey2v@pd.tnic> <20171129161349.d7ksuhwhdamloty6@node.shutemov.name> <alpine.DEB.2.20.1711291740050.1825@nanos> <20171129170831.2iqpop2u534mgrbc@node.shutemov.name> <20171129205815.GE3070@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCHv2 0/4] x86: 5-level related changes into decompression code
From: hpa@zytor.com
Message-ID: <C6812C12-2ABB-486B-99F8-14FD99ABFB98@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On November 29, 2017 12:58:15 PM PST, Andi Kleen <ak@linux=2Eintel=2Ecom> w=
rote:
>> We're really early in the boot -- startup_64 in decompression code --
>and
>> I don't know a way print a message there=2E Is there a way?
>>=20
>> no_longmode handled by just hanging the machine=2E Is it enough for
>no_la57
>> case too?
>
>The way to handle it is to check it early in the real mode boot code
>when you=20
>can still print messages=2E That is how missing long mode is handled=2E
>
>-Andi

Yes, and that test should be done automatically=2E  However, we also check=
 at several later points in case that code is bypassed by the bootloader=2E
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
