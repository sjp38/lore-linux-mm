Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D8156B02E1
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 01:33:04 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id i18so11804615qte.1
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 22:33:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l14si5296867qtb.91.2017.04.27.22.33.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 22:33:03 -0700 (PDT)
Date: Fri, 28 Apr 2017 13:32:33 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH v5 31/32] x86: Add sysfs support for Secure Memory
 Encryption
Message-ID: <20170428053233.GA6149@dhcp-128-65.nay.redhat.com>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212212.10190.73484.stgit@tlendack-t1.amdoffice.net>
 <1498ec98-b19d-c47d-902b-a68870a3f860@intel.com>
 <20170427072547.GB15297@dhcp-128-65.nay.redhat.com>
 <1f034974-20e6-b5e9-e6ff-434b634e1522@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1f034974-20e6-b5e9-e6ff-434b634e1522@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 04/27/17 at 08:52am, Dave Hansen wrote:
> On 04/27/2017 12:25 AM, Dave Young wrote:
> > On 04/21/17 at 02:55pm, Dave Hansen wrote:
> >> On 04/18/2017 02:22 PM, Tom Lendacky wrote:
> >>> Add sysfs support for SME so that user-space utilities (kdump, etc.) can
> >>> determine if SME is active.
> >>>
> >>> A new directory will be created:
> >>>   /sys/kernel/mm/sme/
> >>>
> >>> And two entries within the new directory:
> >>>   /sys/kernel/mm/sme/active
> >>>   /sys/kernel/mm/sme/encryption_mask
> >>
> >> Why do they care, and what will they be doing with this information?
> > 
> > Since kdump will copy old memory but need this to know if the old memory
> > was encrypted or not. With this sysfs file we can know the previous SME
> > status and pass to kdump kernel as like a kernel param.
> > 
> > Tom, have you got chance to try if it works or not?
> 
> What will the kdump kernel do with it though?  We kexec() into that
> kernel so the SME keys will all be the same, right?  So, will the kdump
> kernel be just setting the encryption bit in the PTE so it can copy the
> old plaintext out?

I assume it is for active -> non active case, the new boot need to know
the old memory is encrypted. But I think I did not read all the patches
I may miss things.

> 
> Why do we need both 'active' and 'encryption_mask'?  How could it be
> that the hardware-enumerated 'encryption_mask' changes across a kexec()?

Leave this question to Tom..

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
