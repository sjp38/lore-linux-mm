Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E02796B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 07:31:48 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g13so1939115wmd.9
        for <linux-mm@kvack.org>; Wed, 31 May 2017 04:31:48 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id f85si18560150wmh.76.2017.05.31.04.31.47
        for <linux-mm@kvack.org>;
        Wed, 31 May 2017 04:31:47 -0700 (PDT)
Date: Wed, 31 May 2017 13:31:41 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 17/32] x86/mm: Add support to access boot related data
 in the clear
Message-ID: <20170531113140.fxlxnlo3hod57l53@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211921.10190.1537.stgit@tlendack-t1.amdoffice.net>
 <20170515183517.mb4k2gp2qobbuvtm@pd.tnic>
 <4845df29-bae7-9b78-0428-ff96dbef2128@amd.com>
 <20170518090212.kebstmnjv4h3cjf2@pd.tnic>
 <c0cb8a50-e860-169b-ee0c-7eb4db7c3fda@amd.com>
 <20170521071650.pwwmw4agggaazfrh@pd.tnic>
 <754886ff-b502-3f68-3c32-5355d4176829@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <754886ff-b502-3f68-3c32-5355d4176829@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, May 30, 2017 at 11:46:52AM -0500, Tom Lendacky wrote:
> Check if you have CONFIG_DEBUG_SECTION_MISMATCH=y

$ grep MISM .config
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_SECTION_MISMATCH_WARN_ONLY=y

Still no joy.

Can you give me your .config?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
