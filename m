Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 713666B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 15:37:18 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l10so3988697wmg.5
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 12:37:18 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x6si12285265wrg.476.2017.10.19.12.37.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 12:37:17 -0700 (PDT)
Date: Thu, 19 Oct 2017 21:36:59 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Regression: x86/mm: Add Secure Memory Encryption (SME) support
In-Reply-To: <c0528ed8-2d00-dedf-4f90-8aa7eead4b5a@amd.com>
Message-ID: <alpine.DEB.2.20.1710192126150.2054@nanos>
References: <d5c60048-dbb3-0440-d139-ea325621e654@iam.tj> <c0528ed8-2d00-dedf-4f90-8aa7eead4b5a@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Tj <linux@iam.tj>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Borislav Petkov <bp@suse.de>, Greg KH <greg@kroah.com>

On Mon, 2 Oct 2017, Tom Lendacky wrote:
> On 9/30/2017 5:36 PM, Tj wrote:
> > With 4.14.0rc2 on an Intel CPU with an Nvidia GPU the proprietary nvidia
> > driver (v340.102) fails to modpost due to:
> > 
> > FATAL: modpost: GPL-incompatible module nvidia.ko uses GPL-only symbol
> > 'sme_me_mask'
> > 
> > I think this is due to:
> > 
> > config ARCH_HAS_MEM_ENCRYPT
> >         def_bool y
> > 
> 
> I think this is more likely because of CONFIG_AMD_MEM_ENCRYPT=y. If
> CONFIG_AMD_MEM_ENCRYPT=n then sme_me_mask becomes a #define. I'm
> assuming that changing the sme_me_mask in arch/x86/mm/mem_encrypt.c
> from EXPORT_SYMBOL_GPL to EXPORT_SYMBOL fixes the issue?
> 
> Boris, is it a big deal to make this change if that's the issue?

It's a big deal.

And no, it's GPL and it stays that way. This discussion pops up every few
month when we add a new feature.

If people want to run the nviodit module, then they can set

   CONFIG_AMD_MEM_ENCRYPT=n

and be done with it.

The proprietaery nvidia driver is tolerated as is and it's operating in a
legal grey zone.  That tolerance does not include that the existance of
this driver can dictate our choice of licensing. Especially not if the
reason why it fails to compile or load can be disabled.

There is a choice, but the option for free lunch does not exist.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
