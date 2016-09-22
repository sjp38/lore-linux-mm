Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD5328025B
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 13:27:45 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w84so77283533wmg.1
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 10:27:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 185si3438225wmp.133.2016.09.22.10.27.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 10:27:44 -0700 (PDT)
Date: Thu, 22 Sep 2016 19:27:32 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v1 09/28] x86/efi: Access EFI data as encrypted when
 SEV is active
Message-ID: <20160922172732.egjvbivmf5vmcetk@pd.tnic>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190832511.9523.10850626471583956499.stgit@brijesh-build-machine>
 <20160922143545.3kl7khff6vqk7b2t@pd.tnic>
 <464461b7-1efb-0af1-dd3e-eb919a2578e9@redhat.com>
 <20160922145947.52v42l7p7dl7u3r4@pd.tnic>
 <938ee0cf-85e6-eefa-7df9-9d5e09ed7a9d@redhat.com>
 <20160922170718.34d4ppockeurrg25@pd.tnic>
 <c1a609f0-307e-9c6c-ce33-b562ca5c0624@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c1a609f0-307e-9c6c-ce33-b562ca5c0624@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Brijesh Singh <brijesh.singh@amd.com>, thomas.lendacky@amd.com, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, akpm@linux-foundation.org, davem@davemloft.net

On Thu, Sep 22, 2016 at 07:08:50PM +0200, Paolo Bonzini wrote:
> That's not how I read it.  I just figured that the BIOS has some magic
> things high in the physical address space and if you reduce the physical
> address space the BIOS (which is called from e.g. EFI runtime services)
> would have problems with that.

Yeah, I had to ask about that myself and Tom will have it explained
better in the next version.

The reduction in physical address space happens when SME enabled because
you need a couple of bits in the PTE with which to say which key has
encrypted that page. So it is an indelible part of the SME machinery.

Btw, section "7.10 Secure Memory Encryption" has an initial writeup:

http://support.amd.com/TechDocs/24593.pdf

Now that I skim over it, it doesn't mention the BIOS thing but that'll
be updated.

HTH.

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
