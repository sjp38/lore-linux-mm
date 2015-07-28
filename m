Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 167026B0253
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 11:07:53 -0400 (EDT)
Received: by ykax123 with SMTP id x123so98070979yka.1
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 08:07:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m186si15601035ykf.73.2015.07.28.08.07.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 08:07:52 -0700 (PDT)
Message-ID: <1438096069.14248.13.camel@redhat.com>
Subject: Re: [PATCH 0/2] arm64: support initrd outside of mapped RAM
From: Mark Salter <msalter@redhat.com>
Date: Tue, 28 Jul 2015 11:07:49 -0400
In-Reply-To: <20150728145906.GE15213@leverpostej>
References: <1438093961-15536-1-git-send-email-msalter@redhat.com>
	 <20150728145906.GE15213@leverpostej>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Tue, 2015-07-28 at 15:59 +0100, Mark Rutland wrote:
> Hi Mark,
> 
> As a heads-up, it looks like you missed a space when sending this; Arnd
> and Ard got merged into:
> 
> "Arnd Bergmann <arnd@arndb.de>--cc=Ard Biesheuvel" <
> ard.biesheuvel@linaro.org>
> 
> I've corrected that for this reply.

Oops. Thanks.

> 
> On Tue, Jul 28, 2015 at 03:32:39PM +0100, Mark Salter wrote:
> > When booting an arm64 kernel w/initrd using UEFI/grub, use of mem= will 
> > likely
> > cut off part or all of the initrd. This leaves it outside the kernel 
> > linear
> > map which leads to failure when unpacking. The x86 code has a similar 
> > need to
> > relocate an initrd outside of mapped memory in some cases.
> > 
> > The current x86 code uses early_memremap() to copy the original initrd 
> > from
> > unmapped to mapped RAM. This patchset creates a generic 
> > copy_from_early_mem()
> > utility based on that x86 code and has arm64 use it to relocate the 
> > initrd
> > if necessary.
> 
> This sounds like a sane idea to me.
> 
> > Mark Salter (2):
> >   mm: add utility for early copy from unmapped ram
> >   arm64: support initrd outside kernel linear map
> > 
> >  arch/arm64/kernel/setup.c           | 55 
> > +++++++++++++++++++++++++++++++++++++
> >  include/asm-generic/early_ioremap.h |  6 ++++
> >  mm/early_ioremap.c                  | 22 +++++++++++++++
> >  3 files changed, 83 insertions(+)
> 
> Any reason for not moving x86 over to the new generic version?

I have a patch to do that but I'm not sure how to contrive a
testcase to exercise it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
