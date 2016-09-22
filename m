Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 99BA46B0275
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 15:04:42 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id mi5so164606597pab.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 12:04:42 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0086.outbound.protection.outlook.com. [104.47.40.86])
        by mx.google.com with ESMTPS id s86si3302408pfd.23.2016.09.22.12.04.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 12:04:41 -0700 (PDT)
Subject: Re: [RFC PATCH v1 09/28] x86/efi: Access EFI data as encrypted when
 SEV is active
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190832511.9523.10850626471583956499.stgit@brijesh-build-machine>
 <20160922143545.3kl7khff6vqk7b2t@pd.tnic>
 <464461b7-1efb-0af1-dd3e-eb919a2578e9@redhat.com>
 <20160922145947.52v42l7p7dl7u3r4@pd.tnic>
 <938ee0cf-85e6-eefa-7df9-9d5e09ed7a9d@redhat.com>
 <20160922170718.34d4ppockeurrg25@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <1a22afee-a146-414c-6f58-66a942f7aab9@amd.com>
Date: Thu, 22 Sep 2016 14:04:27 -0500
MIME-Version: 1.0
In-Reply-To: <20160922170718.34d4ppockeurrg25@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>, Paolo Bonzini <pbonzini@redhat.com>
Cc: Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, akpm@linux-foundation.org, davem@davemloft.net

On 09/22/2016 12:07 PM, Borislav Petkov wrote:
> On Thu, Sep 22, 2016 at 05:05:54PM +0200, Paolo Bonzini wrote:
>> Which paragraph?
> 
> "Linux relies on BIOS to set this bit if BIOS has determined that the
> reduction in the physical address space as a result of enabling memory
> encryption..."
> 
> Basically, you can enable SME in the BIOS and you're all set.

That's not what I mean here.  If the BIOS sets the SMEE bit in the
SYS_CFG msr then, even if the encryption bit is never used, there is
still a reduction in physical address space.

Transparent SME (TSME) will be a BIOS option that will result in the
memory controller performing encryption no matter what. In this case
all data will be encrypted without a reduction in physical address
space.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
