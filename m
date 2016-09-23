Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 756EE6B0286
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 05:50:31 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w84so12114996wmg.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 02:50:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id av5si6729697wjc.234.2016.09.23.02.50.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 02:50:30 -0700 (PDT)
Date: Fri, 23 Sep 2016 11:50:15 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v1 09/28] x86/efi: Access EFI data as encrypted when
 SEV is active
Message-ID: <20160923095015.5nn52ekk2kkqixfi@pd.tnic>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190832511.9523.10850626471583956499.stgit@brijesh-build-machine>
 <20160922143545.3kl7khff6vqk7b2t@pd.tnic>
 <443d06f5-2db5-5107-296f-94fabd209407@amd.com>
 <45a56110-95e9-e1f3-83ab-e777b48bf79a@redhat.com>
 <20160922183759.7ahw2kbxit3epnzk@pd.tnic>
 <c2f7bb1d-cf3c-2373-c563-a1e72ff7b83a@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c2f7bb1d-cf3c-2373-c563-a1e72ff7b83a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kai Huang <kaih.linux@gmail.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Tom Lendacky <thomas.lendacky@amd.com>, Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, akpm@linux-foundation.org, davem@davemloft.net

On Fri, Sep 23, 2016 at 09:33:00PM +1200, Kai Huang wrote:
> How is this even possible? The spec clearly says under SEV only in long mode
> or PAE mode guest can control whether memory is encrypted via c-bit, and in
> other modes guest will be always in encrypted mode.

I was suggesting the hypervisor supplies the EFI ranges unencrypted. But
that is not a good idea because firmware data is exposed then, see same
thread from yesterday.

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
