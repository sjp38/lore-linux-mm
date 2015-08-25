Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1B83B6B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 05:15:56 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so119020182pac.2
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 02:15:55 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id il3si31992512pbc.160.2015.08.25.02.15.55
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 02:15:55 -0700 (PDT)
Date: Tue, 25 Aug 2015 10:15:47 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
Message-ID: <20150825091547.GA21300@arm.com>
References: <CAPAsAGy-r8Z2N09wKV+e0kLfbwxd-eWK6N5Xajsnqq9jfyWqcQ@mail.gmail.com>
 <CACRpkdZmHLMxosLXjyOPdkavo=UNzmTcHOLF5vV4cS1ULfbq6A@mail.gmail.com>
 <CAPAsAGw-iawTpjJh66rQN5fqBFT6UBZCcv2eKx7JTqCXzhzpsw@mail.gmail.com>
 <CACRpkdY2i2M27gP_fXawkFrC_GFgWaKr5rEn6d47refNPiEk=g@mail.gmail.com>
 <55AE56DB.4040607@samsung.com>
 <CACRpkdYaqK8upK-3b01JbO_y+sHnk4-Hm1MfvjSy0tKUkFREtQ@mail.gmail.com>
 <20150824131557.GB7557@n2100.arm.linux.org.uk>
 <CACRpkdYwpucRiXM05y00RQY=gKv8W6YjCNspYFRMGaM605cU0w@mail.gmail.com>
 <CAPAsAGwji7FpUJK9O=FWYN15-rJkYMQyOt9W9ncdY9uLybxkiA@mail.gmail.com>
 <20150824174736.GD7557@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150824174736.GD7557@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Linus Walleij <linus.walleij@linaro.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>

On Mon, Aug 24, 2015 at 06:47:36PM +0100, Russell King - ARM Linux wrote:
> On Mon, Aug 24, 2015 at 05:15:22PM +0300, Andrey Ryabinin wrote:
> > Yes, ~130Mb (3G/1G split) should work. 512Mb shadow is optional.
> > The only advantage of 512Mb shadow is better handling of user memory
> > accesses bugs
> > (access to user memory without copy_from_user/copy_to_user/strlen_user etc API).
> 
> No need for that to be handed by KASan.  I have patches in linux-next,
> now acked by Will, which prevent the kernel accessing userspace with
> zero memory footprint.  No need for remapping, we have a way to quickly
> turn off access to userspace mapped pages on non-LPAE 32-bit CPUs.
> (LPAE is not supported yet - Catalin will be working on that using the
> hooks I'm providing once he returns.)

Hey, I only acked the "Efficiency cleanups" series so far! The PAN emulation
is still on my list.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
