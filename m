Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 015B7280256
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 14:44:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b130so79467903wmc.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 11:44:14 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id x128si36618613wme.0.2016.09.22.11.44.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 11:44:13 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id b184so15539822wma.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 11:44:13 -0700 (PDT)
Subject: Re: [RFC PATCH v1 09/28] x86/efi: Access EFI data as encrypted when
 SEV is active
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190832511.9523.10850626471583956499.stgit@brijesh-build-machine>
 <20160922143545.3kl7khff6vqk7b2t@pd.tnic>
 <443d06f5-2db5-5107-296f-94fabd209407@amd.com>
 <45a56110-95e9-e1f3-83ab-e777b48bf79a@redhat.com>
 <20160922183759.7ahw2kbxit3epnzk@pd.tnic>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <127f72bf-978b-e642-20ae-fbdd3a6f94c7@redhat.com>
Date: Thu, 22 Sep 2016 20:44:10 +0200
MIME-Version: 1.0
In-Reply-To: <20160922183759.7ahw2kbxit3epnzk@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vg.kvack.org



On 22/09/2016 20:37, Borislav Petkov wrote:
>> > Unless this is part of some spec, it's easier if things are the same in
>> > SME and SEV.
> Yeah, I was pondering over how sprinkling sev_active checks might not be
> so clean.
> 
> I'm wondering if we could make the EFI regions presented to the guest
> unencrypted too, as part of some SEV-specific init routine so that the
> guest kernel doesn't need to do anything different.

That too, but why not fix it in the firmware?...  (Again, if there's any
MSFT guy looking at this offlist, let's involve him in the discussion).

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
