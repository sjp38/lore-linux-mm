Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B18D6B04A3
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 14:04:24 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e3so120582134pfc.4
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 11:04:24 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0062.outbound.protection.outlook.com. [104.47.38.62])
        by mx.google.com with ESMTPS id b4si8287211pfl.145.2017.07.10.11.04.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 11:04:22 -0700 (PDT)
Subject: Re: [PATCH v9 00/38] x86: Secure Memory Encryption (AMD)
References: <20170707133804.29711.1616.stgit@tlendack-t1.amdoffice.net>
 <20170708092426.prf7xmmnv6xvdqx4@gmail.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <fce185d2-4420-7255-6331-6231c643c8c7@amd.com>
Date: Mon, 10 Jul 2017 13:04:11 -0500
MIME-Version: 1.0
In-Reply-To: <20170708092426.prf7xmmnv6xvdqx4@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>



On 7/8/2017 4:24 AM, Ingo Molnar wrote:
> 
> * Tom Lendacky <thomas.lendacky@amd.com> wrote:
> 
>> This patch series provides support for AMD's new Secure Memory Encryption (SME)
>> feature.
> 
> I'm wondering, what's the typical performance hit to DRAM access latency when SME
> is enabled?

It's about an extra 10 cycles of DRAM latency when performing an
encryption or decryption operation.

> 
> On that same note, if the performance hit is noticeable I'd expect SME to not be
> enabled in native kernels typically - but still it looks like a useful hardware

In some internal testing we've seen about 1.5% or less reduction in
performance. Of course it all depends on the workload: the number of
memory accesses, cache friendliness, etc.

> feature. Since it's controlled at the page table level, have you considered
> allowing SME-activated vmas via mmap(), even on kernels that are otherwise not
> using encrypted DRAM?

That is definitely something to consider as an additional SME-related
feature and something I can look into after this.

Thanks,
Tom

> 
> One would think that putting encryption keys into such encrypted RAM regions would
> generally improve robustness against various physical space attacks that want to
> extract keys but don't have full control of the CPU.
> 
> Thanks,
> 
> 	Ingo
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
