Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 77A8628071E
	for <linux-mm@kvack.org>; Fri, 19 May 2017 16:17:19 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id y31so29253433qty.7
        for <linux-mm@kvack.org>; Fri, 19 May 2017 13:17:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c187si9430922qkg.107.2017.05.19.13.17.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 13:17:18 -0700 (PDT)
Date: Fri, 19 May 2017 15:16:51 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [PATCH v5 32/32] x86/mm: Add support to make use of Secure
 Memory Encryption
Message-ID: <20170519201651.dhayf2pwjlsnouz4@treble>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212223.10190.85121.stgit@tlendack-t1.amdoffice.net>
 <c29edaff-24f2-ee9b-4142-bdbf8c42083f@amd.com>
 <20170519113005.3f5kwzg4pgh7j6a5@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170519113005.3f5kwzg4pgh7j6a5@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Fri, May 19, 2017 at 01:30:05PM +0200, Borislav Petkov wrote:
> > it is called so early. I can get past it by adding:
> > 
> > CFLAGS_mem_encrypt.o := $(nostackp)
> > 
> > in the arch/x86/mm/Makefile, but that obviously eliminates the support
> > for the whole file.  Would it be better to split out the sme_enable()
> > and other boot routines into a separate file or just apply the
> > $(nostackp) to the whole file?
> 
> Josh might have a better idea here... CCed.

I'm the stack validation guy, not the stack protection guy :-)

But there is a way to disable compiler options on a per-function basis
with the gcc __optimize__ function attribute.  For example:

  __attribute__((__optimize__("no-stack-protector")))

-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
