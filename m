Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3CCF76B000A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:26:15 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z5-v6so4243472wro.15
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 08:26:15 -0700 (PDT)
Received: from smtp-out4.electric.net (smtp-out4.electric.net. [192.162.216.183])
        by mx.google.com with ESMTPS id 7-v6si2626912wrh.373.2018.06.29.08.26.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 08:26:14 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v4 0/7] arm64: untag user pointers passed to the kernel
Date: Fri, 29 Jun 2018 15:27:30 +0000
Message-ID: <a53c13e0cff941aa85f023b0f29346af@AcuMS.aculab.com>
References: <cover.1529507994.git.andreyknvl@google.com>
 <CAAeHK+zqtyGzd_CZ7qKZKU-uZjZ1Pkmod5h8zzbN0xCV26nSfg@mail.gmail.com>
 <20180626172900.ufclp2pfrhwkxjco@armageddon.cambridge.arm.com>
 <CAAeHK+yqWKTdTG+ymZ2-5XKiDANV+fmUjnQkRy-5tpgphuLJRA@mail.gmail.com>
 <0cef1643-a523-98e7-95e2-9ec595137642@arm.com>
 <20180627171757.amucnh5znld45cpc@armageddon.cambridge.arm.com>
 <20180628061758.j6bytsaj5jk4aocg@ltop.local>
 <20180628102741.vk6vphfinlj3lvhv@armageddon.cambridge.arm.com>
 <20180628104610.czsnq4w3lfhxrn53@ltop.local>
 <20180628144858.2fu7kq56cxhp2kpg@armageddon.cambridge.arm.com>
In-Reply-To: <20180628144858.2fu7kq56cxhp2kpg@armageddon.cambridge.arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Catalin Marinas' <catalin.marinas@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>, Linux Memory
 Management List <linux-mm@kvack.org>, "linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Evgeniy Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Andrey Konovalov <andreyknvl@google.com>, Ramana
 Radhakrishnan <ramana.radhakrishnan@arm.com>, Al Viro <viro@zeniv.linux.org.uk>nd <nd@arm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Kostya Serebryany <kcc@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <Robin.Murphy@arm.com>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>

From: Catalin Marinas
> Sent: 28 June 2018 15:49
...
> >
> > Mmmm yes.
> > I tend to favor a sort of opposite approach. When we have an address
> > that must not be dereferenced as-such (and sometimes when the address
> > can be from both __user & __kernel space) I prefer to use a ulong
> > which will force the use of the required operation before being
> > able to do any sort of dereferencing and this won't need horrible
> > casts with __force (it, of course, all depends on the full context).
>=20
> I agree. That's what the kernel uses in functions like get_user_pages()
> which take ulong as an argument. Similarly mmap() and friends don't
> expect the pointer to be dereferenced, hence the ulong argument. The
> interesting part that the man page (and the C library header
> declaration) shows such address argument as void *. We could add a
> syscall wrapper in the arch code, only that it doesn't feel consistent
> with the "rule" that ulong addresses are not actually tagged pointers.

For most modern calling conventions it would make sense to put 'user'
addresses (and physical ones from that matter) into a structure.
That way you get much stronger typing from C itself.

The patch would, of course, be huge!

	David
