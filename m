Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9347D6B0069
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 14:51:02 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id y10so174705630qty.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 11:51:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c123si2143924qka.301.2016.09.22.11.51.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 11:51:02 -0700 (PDT)
Subject: Re: [RFC PATCH v1 09/28] x86/efi: Access EFI data as encrypted when
 SEV is active
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190832511.9523.10850626471583956499.stgit@brijesh-build-machine>
 <20160922143545.3kl7khff6vqk7b2t@pd.tnic>
 <464461b7-1efb-0af1-dd3e-eb919a2578e9@redhat.com>
 <0012cd4d-d432-ae14-1041-5e8b62973b37@amd.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <4e93fbb3-d01c-1fd6-0610-56402eb5c242@redhat.com>
Date: Thu, 22 Sep 2016 20:50:42 +0200
MIME-Version: 1.0
In-Reply-To: <0012cd4d-d432-ae14-1041-5e8b62973b37@amd.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>, Borislav Petkov <bp@suse.de>, Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, akpm@linux-foundation.org, davem@davemloft.net



On 22/09/2016 20:47, Tom Lendacky wrote:
> > Because the firmware volume is written to high memory in encrypted form,
> > and because the PEI phase runs in 32-bit mode, the firmware code will be
> > encrypted; on the other hand, data that is placed in low memory for the
> > kernel can be unencrypted, thus limiting differences between SME and SEV.
> 
> I like the idea of limiting the differences but it would leave the EFI
> data and ACPI tables exposed and able to be manipulated.

Hmm, that makes sense.  So I guess this has to stay, and Borislav's
proposal doesn't fly either.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
