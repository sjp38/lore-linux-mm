Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0050183093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 09:06:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so34002843wmz.2
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 06:06:31 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id a7si13597488wjk.240.2016.08.25.06.06.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Aug 2016 06:06:30 -0700 (PDT)
Date: Thu, 25 Aug 2016 15:04:06 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC PATCH v2 04/20] x86: Secure Memory Encryption (SME)
 support
In-Reply-To: <20160822223610.29880.21739.stgit@tlendack-t1.amdoffice.net>
Message-ID: <alpine.DEB.2.20.1608251503340.5714@nanos>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net> <20160822223610.29880.21739.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?ISO-8859-2?Q?Radim_Kr=E8m=E1=F8?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>

On Mon, 22 Aug 2016, Tom Lendacky wrote:

> Provide support for Secure Memory Encryption (SME). This initial support
> defines the memory encryption mask as a variable for quick access and an
> accessor for retrieving the number of physical addressing bits lost if
> SME is enabled.

What is the reason that this needs to live in assembly code?
 
Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
