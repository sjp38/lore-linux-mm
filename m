Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 681636B0038
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 15:04:09 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 187so45132848itk.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 12:04:09 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0058.outbound.protection.outlook.com. [104.47.33.58])
        by mx.google.com with ESMTPS id v1si4336593itb.117.2017.03.16.12.04.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 12:04:08 -0700 (PDT)
Subject: Re: [RFC PATCH v2 05/32] x86: Use encrypted access of BOOT related
 data with SEV
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846757895.2349.561582698953591240.stgit@brijesh-build-machine>
 <20170307110925.zmo7gsflxhui4k7e@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <8715da04-2d25-d1f2-3082-f45750c4f2d9@amd.com>
Date: Thu, 16 Mar 2017 14:03:58 -0500
MIME-Version: 1.0
In-Reply-To: <20170307110925.zmo7gsflxhui4k7e@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>, Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

On 3/7/2017 5:09 AM, Borislav Petkov wrote:
> On Thu, Mar 02, 2017 at 10:12:59AM -0500, Brijesh Singh wrote:
>> From: Tom Lendacky <thomas.lendacky@amd.com>
>>
>> When Secure Encrypted Virtualization (SEV) is active, BOOT data (such as
>> EFI related data, setup data) is encrypted and needs to be accessed as
>> such when mapped. Update the architecture override in early_memremap to
>> keep the encryption attribute when mapping this data.
>
> This could also explain why persistent memory needs to be accessed
> decrypted with SEV.

I'll add some comments about why persistent memory needs to be accessed
decrypted (because the encryption key changes across reboots) for both
SME and SEV.

>
> In general, what the difference in that aspect is in respect to SME. And
> I'd write that in the comment over the function. And not say "E820 areas
> are checked in making this determination." because that is visible but
> say *why* we need to check those ranges and determine access depending
> on their type.

Will do.

Thanks,
Tom

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
