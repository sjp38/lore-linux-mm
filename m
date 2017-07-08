Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D7603440843
	for <linux-mm@kvack.org>; Sat,  8 Jul 2017 05:24:31 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v88so13052377wrb.1
        for <linux-mm@kvack.org>; Sat, 08 Jul 2017 02:24:31 -0700 (PDT)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id q189si1566860wma.70.2017.07.08.02.24.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Jul 2017 02:24:30 -0700 (PDT)
Received: by mail-wr0-x244.google.com with SMTP id z45so12821023wrb.2
        for <linux-mm@kvack.org>; Sat, 08 Jul 2017 02:24:30 -0700 (PDT)
Date: Sat, 8 Jul 2017 11:24:26 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v9 00/38] x86: Secure Memory Encryption (AMD)
Message-ID: <20170708092426.prf7xmmnv6xvdqx4@gmail.com>
References: <20170707133804.29711.1616.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170707133804.29711.1616.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>


* Tom Lendacky <thomas.lendacky@amd.com> wrote:

> This patch series provides support for AMD's new Secure Memory Encryption (SME)
> feature.

I'm wondering, what's the typical performance hit to DRAM access latency when SME 
is enabled?

On that same note, if the performance hit is noticeable I'd expect SME to not be 
enabled in native kernels typically - but still it looks like a useful hardware 
feature. Since it's controlled at the page table level, have you considered 
allowing SME-activated vmas via mmap(), even on kernels that are otherwise not 
using encrypted DRAM?

One would think that putting encryption keys into such encrypted RAM regions would 
generally improve robustness against various physical space attacks that want to 
extract keys but don't have full control of the CPU.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
