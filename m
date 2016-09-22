Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0501C280255
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 10:17:55 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l132so53194648wmf.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 07:17:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kg3si2198360wjb.37.2016.09.22.07.17.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 07:17:53 -0700 (PDT)
Date: Thu, 22 Sep 2016 16:17:39 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v1 05/28] KVM: SVM: prepare for new bit definition in
 nested_ctl
Message-ID: <20160922141739.zgnj6gadzcdtsyut@pd.tnic>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190827232.9523.18200019204059963746.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <147190827232.9523.18200019204059963746.stgit@brijesh-build-machine>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

On Mon, Aug 22, 2016 at 07:24:32PM -0400, Brijesh Singh wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> 
> Currently the nested_ctl variable in the vmcb_control_area structure is
> used to indicate nested paging support. The nested paging support field
> is actually defined as bit 0 of the this field. In order to support a new
> feature flag the usage of the nested_ctl and nested paging support must
> be converted to operate on a single bit.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/svm.h |    2 ++
>  arch/x86/kvm/svm.c         |    7 ++++---
>  2 files changed, 6 insertions(+), 3 deletions(-)

Reviewed-by: Borislav Petkov <bp@suse.de>

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
