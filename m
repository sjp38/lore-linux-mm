Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 971526B0038
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 03:17:57 -0400 (EDT)
Received: by obbgh1 with SMTP id gh1so110344469obb.1
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 00:17:57 -0700 (PDT)
Received: from mail-ob0-x22c.google.com (mail-ob0-x22c.google.com. [2607:f8b0:4003:c01::22c])
        by mx.google.com with ESMTPS id y9si4231553oem.106.2015.04.02.00.17.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Apr 2015 00:17:56 -0700 (PDT)
Received: by obbgh1 with SMTP id gh1so110343981obb.1
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 00:17:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150401215950.GC4027@n2100.arm.linux.org.uk>
References: <CANMBJr68dsbYvvHUzy6U4m4fEM6nq8dVHBH4kLQ=0c4QNOhLPQ@mail.gmail.com>
	<20150327002554.GA5527@verge.net.au>
	<20150327100612.GB1562@arm.com>
	<7hbnj99epe.fsf@deeprootsystems.com>
	<CAKv+Gu_ZHZFm-1eXn+r7fkEHOxqSmj+Q+Mmy7k6LK531vSfAjQ@mail.gmail.com>
	<7h8uec95t2.fsf@deeprootsystems.com>
	<alpine.DEB.2.10.1504011130030.14762@ayla.of.borg>
	<551BBEC5.7070801@arm.com>
	<20150401124007.20c440cc43a482f698f461b8@linux-foundation.org>
	<7hwq1v4iq4.fsf@deeprootsystems.com>
	<20150401215950.GC4027@n2100.arm.linux.org.uk>
Date: Thu, 2 Apr 2015 09:17:56 +0200
Message-ID: <CAMuHMdX95QxqUk7XNnZLWWqZT+0HeL9HzcEkuhevGAp7h6XcQQ@mail.gmail.com>
Subject: Re: [PATCH] mm/migrate: Mark unmap_and_move() "noinline" to avoid ICE
 in gcc 4.7.3
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Kevin Hilman <khilman@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Marc Zyngier <marc.zyngier@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <Will.Deacon@arm.com>, Simon Horman <horms@verge.net.au>, Tyler Baker <tyler.baker@linaro.org>, Nishanth Menon <nm@ti.com>, Arnd Bergmann <arnd@arndb.de>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Magnus Damm <magnus.damm@gmail.com>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Russell,

On Wed, Apr 1, 2015 at 11:59 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Wed, Apr 01, 2015 at 02:54:59PM -0700, Kevin Hilman wrote:
>> Your patch on top of Geert's still compiles fine for me with gcc-4.7.3.
>> However, I'm not sure how specific we can be on the versions.
>>
>> /me goes to test a few more compilers...   OK...
>>
>> ICE: 4.7.1, 4.7.3, 4.8.3
>> OK: 4.6.3, 4.9.2, 4.9.3
>>
>> The diff below[2] on top of yours compiles fine here and at least covers
>> the compilers I *know* to trigger the ICE.
>
> Interesting.  I'm using stock gcc 4.7.4 here, though I'm not building
> -next (only mainline + my tree + arm-soc) and it hasn't shown a problem
> yet.

Mainline doesn't fail.

> I think we need to ask the question: is the bug in stock GCC or Linaro
> GCC?  If it's not in stock GCC, then it's a GCC vendor problem :)

Can you please try -next (e.g. next-20150320)?

make bockw_defconfig
make mm/migrate.o

Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
