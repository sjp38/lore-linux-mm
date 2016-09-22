Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 75EAB6B0273
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 11:00:30 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l138so73946392wmg.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 08:00:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m135si2853603wmg.47.2016.09.22.08.00.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 08:00:27 -0700 (PDT)
Date: Thu, 22 Sep 2016 17:00:20 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v1 04/28] x86: Secure Encrypted Virtualization (SEV)
 support
Message-ID: <20160922150020.zzfc3w642r2r6cl2@pd.tnic>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190825949.9523.11406635622434950066.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <147190825949.9523.11406635622434950066.stgit@brijesh-build-machine>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

On Mon, Aug 22, 2016 at 07:24:19PM -0400, Brijesh Singh wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>

Subject: [RFC PATCH v1 04/28] x86: Secure Encrypted Virtualization (SEV) support

Please start patch commit heading with a verb, i.e.:

"x86: Add AMD Secure Encrypted Virtualization (SEV) support"

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
