Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 541D06B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 11:49:03 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i77so3762171wmh.10
        for <linux-mm@kvack.org>; Wed, 31 May 2017 08:49:03 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id l33si4220460wrc.111.2017.05.31.08.49.01
        for <linux-mm@kvack.org>;
        Wed, 31 May 2017 08:49:02 -0700 (PDT)
Date: Wed, 31 May 2017 17:48:54 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 28/32] x86/mm, kexec: Allow kexec to be used with SME
Message-ID: <20170531154854.4tf4rmivgmixc275@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212121.10190.94885.stgit@tlendack-t1.amdoffice.net>
 <5927AC6E.8080209@redhat.com>
 <de4d2efc-6636-4120-98d9-7fdf4707f68d@amd.com>
 <592EDB58.4090903@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <592EDB58.4090903@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xlpang@redhat.com, Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On Wed, May 31, 2017 at 11:03:52PM +0800, Xunlei Pang wrote:
> For kdump case, it will be put in some reserved crash memory allocated
> by kexec-tools, and passed the corresponding start address of the
> allocated reserved crash memory to kdump kernel via "elfcorehdr=",
> please see kernel functions setup_elfcorehdr() and vmcore_init() for
> how it is parsed by kdump kernel.

... which could be a great way to pass the SME status to the second
kernel without any funky sysfs games.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
