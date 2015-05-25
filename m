Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 50A396B01A7
	for <linux-mm@kvack.org>; Mon, 25 May 2015 18:36:34 -0400 (EDT)
Received: by padbw4 with SMTP id bw4so78142143pad.0
        for <linux-mm@kvack.org>; Mon, 25 May 2015 15:36:34 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id tg11si17938385pac.21.2015.05.25.15.36.32
        for <linux-mm@kvack.org>;
        Mon, 25 May 2015 15:36:33 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH 2/2] arm64: Implement vmalloc based thread_info allocator
From: Catalin Marinas <catalin.marinas@foss.arm.com>
In-Reply-To: <5601369.jDWtB6nFJC@wuerfel>
Date: Tue, 26 May 2015 01:36:29 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <1CD6E4BA-95AF-420C-8270-6AAF783B6F60@foss.arm.com>
References: <1432483340-23157-1-git-send-email-jungseoklee85@gmail.com> <B873B881-4972-4524-B1D9-4BB05D7248A4@gmail.com> <F68D2983-226C-4704-A1E0-E79C9425B822@foss.arm.com> <5601369.jDWtB6nFJC@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Jungseok Lee <jungseoklee85@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, "barami97@gmail.com" <barami97@gmail.com>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 25 May 2015, at 23:29, Arnd Bergmann <arnd@arndb.de> wrote:
> On Monday 25 May 2015 19:47:15 Catalin Marinas wrote:
>> On 25 May 2015, at 13:01, Jungseok Lee <jungseoklee85@gmail.com> wrote:
>>>> Could the stack size be reduced to 8KB perhaps?
>>>=20
>>> I guess probably not.
>>>=20
>>> A commit, 845ad05e, says that 8KB is not enough to cover SpecWeb benchma=
rk.
>>=20
>> We could go back to 8KB stacks if we implement support for separate IRQ=20=

>> stack on arm64. It's not too complicated, we would have to use SP0 for (k=
ernel) threads=20
>> and SP1 for IRQ handlers.
>=20
> I think most architectures that see a lot of benchmarks have moved to
> irqstacks at some point, that definitely sounds like a useful idea,
> even if the implementation turns out to be a bit more tricky than
> what you describe.

Of course, it's more complicated than just setting up two stacks (but I'm aw=
ay for a=20
week and writing from a phone). We would need to deal with the initial per-C=
PU setup,=20
rescheduling following an IRQ, CPU on following power management and maybe=20=

other issues. However, the architecture helps us a bit by allowing both SP0 a=
nd SP1 to be=20
used at EL1.=20

> There are a lot of workloads that would benefit from having lower
> per-thread memory cost.

If we keep the 16KB stack, is there any advantage in a separate IRQ one (ass=
uming=20
that we won't overflow 16KB)?

Catalin=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
