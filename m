Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA3C06B0260
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 11:30:13 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w143so42977693wmw.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:30:13 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id r3si5066335wjl.28.2016.04.27.08.30.11
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 08:30:11 -0700 (PDT)
Date: Wed, 27 Apr 2016 17:30:10 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH v1 02/18] x86: Secure Memory Encryption (SME) build
 enablement
Message-ID: <20160427153010.GA7861@amd>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225614.13567.47487.stgit@tlendack-t1.amdoffice.net>
 <20160322130150.GB16528@xo-6d-61-c0.localdomain>
 <5720D810.9060602@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5720D810.9060602@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed 2016-04-27 10:17:36, Tom Lendacky wrote:
> On 03/22/2016 08:01 AM, Pavel Machek wrote:
> > On Tue 2016-04-26 17:56:14, Tom Lendacky wrote:
> >> Provide the Kconfig support to build the SME support in the kernel.
> > 
> > 
> > Probably should go last in the series?
> 
> Yeah, I've seen arguments both ways for this. Doing it early
> allows compiling and testing with it enabled and doing it late
> doesn't enable anything until it's all there. I just chose the
> former.

Doing it early will break bisect, right?
							Pavel

> >> +config AMD_MEM_ENCRYPT
> >> +	bool "Secure Memory Encryption support for AMD"
> >> +	depends on X86_64 && CPU_SUP_AMD
> >> +	---help---
> >> +	  Say yes to enable the encryption of system memory. This requires
> >> +	  an AMD processor that supports Secure Memory Encryption (SME).
> >> +	  The encryption of system memory is disabled by default but can be
> >> +	  enabled with the mem_encrypt=on command line option.
> >> +
> >>  # Common NUMA Features
> >>  config NUMA
> >>  	bool "Numa Memory Allocation and Scheduler Support"
> > 

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
