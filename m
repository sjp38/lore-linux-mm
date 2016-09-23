Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 45B536B0281
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 05:33:18 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id wk8so193674737pab.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 02:33:18 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id l14si6551270pfi.217.2016.09.23.02.33.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 02:33:17 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id q2so5025190pfj.0
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 02:33:17 -0700 (PDT)
Subject: Re: [RFC PATCH v1 09/28] x86/efi: Access EFI data as encrypted when
 SEV is active
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190832511.9523.10850626471583956499.stgit@brijesh-build-machine>
 <20160922143545.3kl7khff6vqk7b2t@pd.tnic>
 <443d06f5-2db5-5107-296f-94fabd209407@amd.com>
 <45a56110-95e9-e1f3-83ab-e777b48bf79a@redhat.com>
 <20160922183759.7ahw2kbxit3epnzk@pd.tnic>
From: Kai Huang <kaih.linux@gmail.com>
Message-ID: <c2f7bb1d-cf3c-2373-c563-a1e72ff7b83a@gmail.com>
Date: Fri, 23 Sep 2016 21:33:00 +1200
MIME-Version: 1.0
In-Reply-To: <20160922183759.7ahw2kbxit3epnzk@pd.tnic>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>, Paolo Bonzini <pbonzini@redhat.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, akpm@linux-foundation.org, davem@davemloft.net



On 23/09/16 06:37, Borislav Petkov wrote:
> On Thu, Sep 22, 2016 at 08:23:36PM +0200, Paolo Bonzini wrote:
>> Unless this is part of some spec, it's easier if things are the same in
>> SME and SEV.
> Yeah, I was pondering over how sprinkling sev_active checks might not be
> so clean.
>
> I'm wondering if we could make the EFI regions presented to the guest
> unencrypted too, as part of some SEV-specific init routine so that the
> guest kernel doesn't need to do anything different.
How is this even possible? The spec clearly says under SEV only in long 
mode or PAE mode guest can control whether memory is encrypted via 
c-bit, and in other modes guest will be always in encrypted mode. Guest 
EFI is also virtual, so are you suggesting EFI code (or code which loads 
EFI) should also be modified to load EFI as unencrypted? Looks it's not 
even possible to happen.

Thanks,
-Kai
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
