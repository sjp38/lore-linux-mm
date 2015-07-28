Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 97EE96B0255
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:59:36 -0400 (EDT)
Received: by igbij6 with SMTP id ij6so119622868igb.1
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 07:59:36 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ap10si19665259icc.72.2015.07.28.07.59.36
        for <linux-mm@kvack.org>;
        Tue, 28 Jul 2015 07:59:36 -0700 (PDT)
Date: Tue, 28 Jul 2015 15:59:06 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 0/2] arm64: support initrd outside of mapped RAM
Message-ID: <20150728145906.GE15213@leverpostej>
References: <1438093961-15536-1-git-send-email-msalter@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438093961-15536-1-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Salter <msalter@redhat.com>
Cc: Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

Hi Mark,

As a heads-up, it looks like you missed a space when sending this; Arnd
and Ard got merged into:

"Arnd Bergmann <arnd@arndb.de>--cc=Ard Biesheuvel" <ard.biesheuvel@linaro.org>

I've corrected that for this reply.

On Tue, Jul 28, 2015 at 03:32:39PM +0100, Mark Salter wrote:
> When booting an arm64 kernel w/initrd using UEFI/grub, use of mem= will likely
> cut off part or all of the initrd. This leaves it outside the kernel linear
> map which leads to failure when unpacking. The x86 code has a similar need to
> relocate an initrd outside of mapped memory in some cases.
> 
> The current x86 code uses early_memremap() to copy the original initrd from
> unmapped to mapped RAM. This patchset creates a generic copy_from_early_mem()
> utility based on that x86 code and has arm64 use it to relocate the initrd
> if necessary.

This sounds like a sane idea to me.

> Mark Salter (2):
>   mm: add utility for early copy from unmapped ram
>   arm64: support initrd outside kernel linear map
> 
>  arch/arm64/kernel/setup.c           | 55 +++++++++++++++++++++++++++++++++++++
>  include/asm-generic/early_ioremap.h |  6 ++++
>  mm/early_ioremap.c                  | 22 +++++++++++++++
>  3 files changed, 83 insertions(+)

Any reason for not moving x86 over to the new generic version?

Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
