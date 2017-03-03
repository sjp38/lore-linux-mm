Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 236826B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 04:53:12 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id p85so51996400lfg.5
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 01:53:12 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id x12si5714502ljd.36.2017.03.03.01.53.10
        for <linux-mm@kvack.org>;
        Fri, 03 Mar 2017 01:53:10 -0800 (PST)
Date: Fri, 3 Mar 2017 10:52:23 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v4 11/28] x86: Add support to determine the E820 type
 of an address
Message-ID: <20170303095223.eri4u4l7agofqri7@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154430.19244.95519.stgit@tlendack-t1.amdoffice.net>
 <20170220200955.32e2wqxgulswnr55@pd.tnic>
 <e6146786-16c5-99ab-52c9-2bdd50c7d9ba@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <e6146786-16c5-99ab-52c9-2bdd50c7d9ba@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Feb 28, 2017 at 04:34:39PM -0600, Tom Lendacky wrote:
> Or if we want to guard against ACPI adding a type 0 in the future, I
> could make the function return an int and then return -EINVAL if an e820
> entry isn't found.  This might be the better option.

Yap, think so too. I don't trust specs anyway :)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
