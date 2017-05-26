Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B6CE66B02C3
	for <linux-mm@kvack.org>; Fri, 26 May 2017 11:47:47 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id q81so9742170itc.9
        for <linux-mm@kvack.org>; Fri, 26 May 2017 08:47:47 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0052.outbound.protection.outlook.com. [104.47.32.52])
        by mx.google.com with ESMTPS id y143si2373588itb.47.2017.05.26.08.47.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 May 2017 08:47:46 -0700 (PDT)
Subject: Re: [PATCH v5 31/32] x86: Add sysfs support for Secure Memory
 Encryption
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212212.10190.73484.stgit@tlendack-t1.amdoffice.net>
 <20170518170153.eqiyat5s6q3yeejl@pd.tnic>
 <20170526024933.GA3228@dhcp-128-65.nay.redhat.com>
 <5927B767.3010701@redhat.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <d05fa3d2-54d7-f317-b31f-3123f638dd25@amd.com>
Date: Fri, 26 May 2017 10:47:39 -0500
MIME-Version: 1.0
In-Reply-To: <5927B767.3010701@redhat.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xlpang@redhat.com, Dave Young <dyoung@redhat.com>, Borislav Petkov <bp@alien8.de>
Cc: linux-efi@vger.kernel.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, x86@kernel.org, linux-mm@kvack.org, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, linux-arch@vger.kernel.org, kvm@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, "Michael S. Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>

On 5/26/2017 12:04 AM, Xunlei Pang wrote:
> On 05/26/2017 at 10:49 AM, Dave Young wrote:
>> Ccing Xunlei he is reading the patches see what need to be done for
>> kdump. There should still be several places to handle to make kdump work.
>>
>> On 05/18/17 at 07:01pm, Borislav Petkov wrote:
>>> On Tue, Apr 18, 2017 at 04:22:12PM -0500, Tom Lendacky wrote:
>>>> Add sysfs support for SME so that user-space utilities (kdump, etc.) can
>>>> determine if SME is active.
>>> But why do user-space tools need to know that?
>>>
>>> I mean, when we load the kdump kernel, we do it with the first kernel,
>>> with the kexec_load() syscall, AFAICT. And that code does a lot of
>>> things during that init, like machine_kexec_prepare()->init_pgtable() to
>>> prepare the ident mapping of the second kernel, for example.
>>>
>>> What I'm aiming at is that the first kernel knows *exactly* whether SME
>>> is enabled or not and doesn't need to tell the second one through some
>>> sysfs entries - it can do that during loading.
>>>
>>> So I don't think we need any userspace things at all...
>> If kdump kernel can get the SME status from hardware register then this
>> should be not necessary and this patch can be dropped.
>
> Yes, I also agree with dropping this one.

Consensus is to drop, so it will be.

Thanks,
Tom

>
> Regards,
> Xunlei
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
