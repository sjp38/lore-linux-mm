Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id E7B9428025D
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 15:49:32 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id i193so227785193oib.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 12:49:32 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0053.outbound.protection.outlook.com. [104.47.37.53])
        by mx.google.com with ESMTPS id o204si3014007oib.40.2016.09.22.12.49.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 12:49:31 -0700 (PDT)
Subject: Re: [RFC PATCH v1 09/28] x86/efi: Access EFI data as encrypted when
 SEV is active
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190832511.9523.10850626471583956499.stgit@brijesh-build-machine>
 <20160922143545.3kl7khff6vqk7b2t@pd.tnic>
 <464461b7-1efb-0af1-dd3e-eb919a2578e9@redhat.com>
 <20160922145947.52v42l7p7dl7u3r4@pd.tnic>
 <938ee0cf-85e6-eefa-7df9-9d5e09ed7a9d@redhat.com>
 <20160922170718.34d4ppockeurrg25@pd.tnic>
 <1a22afee-a146-414c-6f58-66a942f7aab9@amd.com>
 <20160922191138.lnp4ac3cfkiebjo3@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <e162ecbf-f0b5-9a38-fdf6-7f097e20c5ad@amd.com>
Date: Thu, 22 Sep 2016 14:49:22 -0500
MIME-Version: 1.0
In-Reply-To: <20160922191138.lnp4ac3cfkiebjo3@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, akpm@linux-foundation.org, davem@davemloft.net

On 09/22/2016 02:11 PM, Borislav Petkov wrote:
> On Thu, Sep 22, 2016 at 02:04:27PM -0500, Tom Lendacky wrote:
>> That's not what I mean here.  If the BIOS sets the SMEE bit in the
>> SYS_CFG msr then, even if the encryption bit is never used, there is
>> still a reduction in physical address space.
> 
> I thought that reduction is the reservation of bits for the SME mask.
> 
> What other reduction is there?

There is a reduction in physical address space for the SME mask and the
bits used to aid in identifying the ASID associated with the memory
request. This allows for the memory controller to determine the key to
be used for the encryption operation (host/hypervisor key vs. an SEV
guest key).

Thanks,
Tom

> 
>> Transparent SME (TSME) will be a BIOS option that will result in the
>> memory controller performing encryption no matter what. In this case
>> all data will be encrypted without a reduction in physical address
>> space.
> 
> Now I'm confused: aren't we reducing the address space with the SME
> mask?
> 
> Or what reduction do you mean?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
