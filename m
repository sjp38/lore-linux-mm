Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 56EA96B0292
	for <linux-mm@kvack.org>; Fri, 26 May 2017 22:18:20 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id c75so8117074qka.7
        for <linux-mm@kvack.org>; Fri, 26 May 2017 19:18:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d85si2527112qkb.251.2017.05.26.19.18.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 May 2017 19:18:17 -0700 (PDT)
Date: Sat, 27 May 2017 10:17:57 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH v5 28/32] x86/mm, kexec: Allow kexec to be used with SME
Message-ID: <20170527021757.GA3132@dhcp-128-65.nay.redhat.com>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212121.10190.94885.stgit@tlendack-t1.amdoffice.net>
 <5927AC6E.8080209@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5927AC6E.8080209@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xlpang@redhat.com
Cc: Tom Lendacky <thomas.lendacky@amd.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 05/26/17 at 12:17pm, Xunlei Pang wrote:
> On 04/19/2017 at 05:21 AM, Tom Lendacky wrote:
> > Provide support so that kexec can be used to boot a kernel when SME is
> > enabled.
> >
> > Support is needed to allocate pages for kexec without encryption.  This
> > is needed in order to be able to reboot in the kernel in the same manner
> > as originally booted.
> 
> Hi Tom,
> 
> Looks like kdump will break, I didn't see the similar handling for kdump cases, see kernel:
>     kimage_alloc_crash_control_pages(), kimage_load_crash_segment(), etc.
> 
> We need to support kdump with SME, kdump kernel/initramfs/purgatory/elfcorehdr/etc
> are all loaded into the reserved memory(see crashkernel=X) by userspace kexec-tools.

For kexec_load, it is loaded by kexec-tools, we have in kernel loader
syscall kexec_file_load, it is handled in kernel.

> I think a straightforward way would be to mark the whole reserved memory range without
> encryption before loading all the kexec segments for kdump, I guess we can handle this
> easily in arch_kexec_unprotect_crashkres().
> 
> Moreover, now that "elfcorehdr=X" is left as decrypted, it needs to be remapped to the
> encrypted data.

Tom, could you have a try on kdump according to suggestion from Xunlei?
It is just based on theoretical patch understanding, there could be
other issues when you work on it. Feel free to ask if we can help on
anything.

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
