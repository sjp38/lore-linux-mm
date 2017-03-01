Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 92F9E6B038B
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 12:51:48 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id n76so52146538ioe.1
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 09:51:48 -0800 (PST)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0043.outbound.protection.outlook.com. [104.47.36.43])
        by mx.google.com with ESMTPS id 62si6327883ioh.134.2017.03.01.09.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 09:51:47 -0800 (PST)
Subject: Re: [RFC PATCH v4 00/28] x86: Secure Memory Encryption (AMD)
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170301091725.GA8353@dhcp-128-65.nay.redhat.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <8d1d416c-0ae3-ee87-7c7e-eb15a515eb16@amd.com>
Date: Wed, 1 Mar 2017 11:51:40 -0600
MIME-Version: 1.0
In-Reply-To: <20170301091725.GA8353@dhcp-128-65.nay.redhat.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, kexec@lists.infradead.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 3/1/2017 3:17 AM, Dave Young wrote:
> Hi Tom,

Hi Dave,

>

... SNIP ...

>> - Added support for (re)booting with kexec
>
> Could you please add kexec list in cc when you updating the patches so
> that kexec/kdump people do not miss them?
>

Sorry about that, I'll be sure to add it to the cc list.

Thanks,
Tom

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
