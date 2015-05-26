Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 561EB6B0158
	for <linux-mm@kvack.org>; Tue, 26 May 2015 09:02:52 -0400 (EDT)
Received: by padbw4 with SMTP id bw4so92431087pad.0
        for <linux-mm@kvack.org>; Tue, 26 May 2015 06:02:52 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id pg6si20804077pbb.168.2015.05.26.06.02.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 06:02:51 -0700 (PDT)
Received: by pabru16 with SMTP id ru16so92458949pab.1
        for <linux-mm@kvack.org>; Tue, 26 May 2015 06:02:51 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] arm64: Implement vmalloc based thread_info allocator
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Jungseok Lee <jungseoklee85@gmail.com>
In-Reply-To: <F68D2983-226C-4704-A1E0-E79C9425B822@foss.arm.com>
Date: Tue, 26 May 2015 22:02:46 +0900
Content-Transfer-Encoding: quoted-printable
Message-Id: <E71E3520-FCE5-4DAE-969D-F59F6A331611@gmail.com>
References: <1432483340-23157-1-git-send-email-jungseoklee85@gmail.com> <5992243.NYDGjLH37z@wuerfel> <B873B881-4972-4524-B1D9-4BB05D7248A4@gmail.com> <F68D2983-226C-4704-A1E0-E79C9425B822@foss.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@foss.arm.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, "barami97@gmail.com" <barami97@gmail.com>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On May 26, 2015, at 1:47 AM, Catalin Marinas wrote:
> On 25 May 2015, at 13:01, Jungseok Lee <jungseoklee85@gmail.com> =
wrote:
>=20
>>> Could the stack size be reduced to 8KB perhaps?
>>=20
>> I guess probably not.
>>=20
>> A commit, 845ad05e, says that 8KB is not enough to cover SpecWeb =
benchmark.
>=20
> We could go back to 8KB stacks if we implement support for separate =
IRQ=20
> stack on arm64. It's not too complicated, we would have to use SP0 for =
(kernel) threads=20
> and SP1 for IRQ handlers.

Definitely interesting.

It looks like there are two options based on discussion.
1) Reduce the stack size with separate IRQ stack scheme
2) Figure out a generic anti-fragmentation solution

Do I miss anything?

I am still not sure about the first scheme as reviewing Minchan's =
findings repeatedly,
but I agree that the item should be worked actively.

Best Regards
Jungseok Lee=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
