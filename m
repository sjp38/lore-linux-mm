Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B85946B027C
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 15:11:51 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l132so60442029wmf.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 12:11:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 14si3910634wmn.119.2016.09.22.12.11.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 12:11:50 -0700 (PDT)
Date: Thu, 22 Sep 2016 21:11:38 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v1 09/28] x86/efi: Access EFI data as encrypted when
 SEV is active
Message-ID: <20160922191138.lnp4ac3cfkiebjo3@pd.tnic>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190832511.9523.10850626471583956499.stgit@brijesh-build-machine>
 <20160922143545.3kl7khff6vqk7b2t@pd.tnic>
 <464461b7-1efb-0af1-dd3e-eb919a2578e9@redhat.com>
 <20160922145947.52v42l7p7dl7u3r4@pd.tnic>
 <938ee0cf-85e6-eefa-7df9-9d5e09ed7a9d@redhat.com>
 <20160922170718.34d4ppockeurrg25@pd.tnic>
 <1a22afee-a146-414c-6f58-66a942f7aab9@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1a22afee-a146-414c-6f58-66a942f7aab9@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, akpm@linux-foundation.org, davem@davemloft.net

On Thu, Sep 22, 2016 at 02:04:27PM -0500, Tom Lendacky wrote:
> That's not what I mean here.  If the BIOS sets the SMEE bit in the
> SYS_CFG msr then, even if the encryption bit is never used, there is
> still a reduction in physical address space.

I thought that reduction is the reservation of bits for the SME mask.

What other reduction is there?

> Transparent SME (TSME) will be a BIOS option that will result in the
> memory controller performing encryption no matter what. In this case
> all data will be encrypted without a reduction in physical address
> space.

Now I'm confused: aren't we reducing the address space with the SME
mask?

Or what reduction do you mean?

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
