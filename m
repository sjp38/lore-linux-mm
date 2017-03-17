Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3646B038A
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 07:03:56 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a6so39437672lfa.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 04:03:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t65si6185869qkg.35.2017.03.17.04.03.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 04:03:45 -0700 (PDT)
Subject: Re: [RFC PATCH v2 14/32] x86: mm: Provide support to use memblock
 when spliting large pages
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846771545.2349.9373586041426414252.stgit@brijesh-build-machine>
 <20170310110657.hophlog2juw5hpzz@pd.tnic>
 <cb6a9a56-2c52-d98d-3ff6-3b61d0e5875e@amd.com>
 <20170316182836.tyvxoeq56thtc4pd@pd.tnic>
 <ec134379-6a48-905c-26e4-f6f2738814dc@redhat.com>
 <20170317101737.icdois7sdmtutt6b@pd.tnic>
 <b6f9f46c-58c4-a19c-4955-2d07bd411443@redhat.com>
 <20170317105610.musvo4baokgssvye@pd.tnic>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <78c99889-f175-f60f-716b-34a62203418a@redhat.com>
Date: Fri, 17 Mar 2017 12:03:31 +0100
MIME-Version: 1.0
In-Reply-To: <20170317105610.musvo4baokgssvye@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org



On 17/03/2017 11:56, Borislav Petkov wrote:
>> Theoretically or practically?
> In the sense, it needs to be tried first to see how ugly it can get.
> 
>> It only looks at the E820 map, doesn't it?  Why does it have to do
>> anything with percpu memory areas?
> That's irrelevant. What we want to do is take what's in init_mm.pgd and
> modify it. And use the facilities in arch/x86/mm/init_{32,64}.c because
> they already know about early/late pagetable pages allocation and they
> deal with the kernel pagetable anyway.

If it is possible to do it in a fairly hypervisor-independent manner,
I'm all for it.  That is, only by looking at AMD-specified CPUID leaves
and at kernel ELF sections.

Paolo

> And *not* teach pageattr.c about memblock because that can be misused,
> as tglx pointed out on IRC.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
