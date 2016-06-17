Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A6F0B6B025E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 11:51:49 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c82so212330wme.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 08:51:49 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id 67si2403898wmd.46.2016.06.17.08.51.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 08:51:48 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id v199so3438729wmv.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 08:51:48 -0700 (PDT)
Date: Fri, 17 Jun 2016 16:51:45 +0100
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [RFC PATCH v1 10/18] x86/efi: Access EFI related tables in the
 clear
Message-ID: <20160617155145.GJ2658@codeblueprint.co.uk>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225740.13567.85438.stgit@tlendack-t1.amdoffice.net>
 <20160608111844.GV2658@codeblueprint.co.uk>
 <5759B67A.4000800@amd.com>
 <20160613135110.GC2658@codeblueprint.co.uk>
 <57615561.4090502@amd.com>
 <5762B9E7.80903@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5762B9E7.80903@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Thu, 16 Jun, at 09:38:31AM, Tom Lendacky wrote:
> 
> Ok, I think this was happening before the commit to build our own
> EFI page table structures:
> 
> commit 67a9108ed ("x86/efi: Build our own page table structures")
> 
> Before this commit the boot services ended up mapped into the kernel
> page table entries as un-encrypted during efi_map_regions() and I needed
> to change those entries back to encrypted. With your change above,
> this appears to no longer be needed.

Great news! Things are as they should be ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
