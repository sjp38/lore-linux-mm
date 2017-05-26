Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 29E196B0292
	for <linux-mm@kvack.org>; Fri, 26 May 2017 01:03:18 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id y31so93018qty.7
        for <linux-mm@kvack.org>; Thu, 25 May 2017 22:03:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h42si5357303qtc.247.2017.05.25.22.03.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 22:03:17 -0700 (PDT)
Reply-To: xlpang@redhat.com
Subject: Re: [PATCH v5 31/32] x86: Add sysfs support for Secure Memory
 Encryption
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212212.10190.73484.stgit@tlendack-t1.amdoffice.net>
 <20170518170153.eqiyat5s6q3yeejl@pd.tnic>
 <20170526024933.GA3228@dhcp-128-65.nay.redhat.com>
From: Xunlei Pang <xpang@redhat.com>
Message-ID: <5927B767.3010701@redhat.com>
Date: Fri, 26 May 2017 13:04:39 +0800
MIME-Version: 1.0
In-Reply-To: <20170526024933.GA3228@dhcp-128-65.nay.redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>, Borislav Petkov <bp@alien8.de>
Cc: linux-efi@vger.kernel.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, x86@kernel.org, linux-mm@kvack.org, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, linux-arch@vger.kernel.org, kvm@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tom Lendacky <thomas.lendacky@amd.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xlpang@redhat.com, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, "Michael S. Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>

On 05/26/2017 at 10:49 AM, Dave Young wrote:
> Ccing Xunlei he is reading the patches see what need to be done for
> kdump. There should still be several places to handle to make kdump work.
>
> On 05/18/17 at 07:01pm, Borislav Petkov wrote:
>> On Tue, Apr 18, 2017 at 04:22:12PM -0500, Tom Lendacky wrote:
>>> Add sysfs support for SME so that user-space utilities (kdump, etc.) can
>>> determine if SME is active.
>> But why do user-space tools need to know that?
>>
>> I mean, when we load the kdump kernel, we do it with the first kernel,
>> with the kexec_load() syscall, AFAICT. And that code does a lot of
>> things during that init, like machine_kexec_prepare()->init_pgtable() to
>> prepare the ident mapping of the second kernel, for example.
>>
>> What I'm aiming at is that the first kernel knows *exactly* whether SME
>> is enabled or not and doesn't need to tell the second one through some
>> sysfs entries - it can do that during loading.
>>
>> So I don't think we need any userspace things at all...
> If kdump kernel can get the SME status from hardware register then this
> should be not necessary and this patch can be dropped.

Yes, I also agree with dropping this one.

Regards,
Xunlei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
