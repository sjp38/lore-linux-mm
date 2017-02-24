Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 844A86B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 04:57:18 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id q39so9063182wrb.3
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 01:57:18 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id h61si9644618wrh.186.2017.02.24.01.57.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 01:57:17 -0800 (PST)
Received: by mail-wm0-x22e.google.com with SMTP id v186so10436912wmd.0
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 01:57:17 -0800 (PST)
Date: Fri, 24 Feb 2017 09:57:15 +0000
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [RFC PATCH v4 13/28] efi: Update efi_mem_type() to return
 defined EFI mem types
Message-ID: <20170224095715.GW28416@codeblueprint.co.uk>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154457.19244.5369.stgit@tlendack-t1.amdoffice.net>
 <20170221120505.GQ28416@codeblueprint.co.uk>
 <41d5df05-14be-ff33-a7e2-6b2f51e2605a@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41d5df05-14be-ff33-a7e2-6b2f51e2605a@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On Thu, 23 Feb, at 11:27:55AM, Tom Lendacky wrote:
> 
> I can do that, I'll change the return type to an int. For the
> !efi_enabled I can return -ENOTSUPP and for when an entry isn't
> found I can return -EINVAL.  Sound good?
 
Sounds good to me!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
