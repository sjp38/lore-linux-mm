Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7AF6B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 07:34:10 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c5so3256843wmi.0
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 04:34:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d7si10823025wra.84.2017.03.17.04.34.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 04:34:08 -0700 (PDT)
Date: Fri, 17 Mar 2017 12:33:47 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v2 14/32] x86: mm: Provide support to use memblock
 when spliting large pages
Message-ID: <20170317113337.syvpat3c4s2l4nuz@pd.tnic>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846771545.2349.9373586041426414252.stgit@brijesh-build-machine>
 <20170310110657.hophlog2juw5hpzz@pd.tnic>
 <cb6a9a56-2c52-d98d-3ff6-3b61d0e5875e@amd.com>
 <20170316182836.tyvxoeq56thtc4pd@pd.tnic>
 <ec134379-6a48-905c-26e4-f6f2738814dc@redhat.com>
 <20170317101737.icdois7sdmtutt6b@pd.tnic>
 <b6f9f46c-58c4-a19c-4955-2d07bd411443@redhat.com>
 <20170317105610.musvo4baokgssvye@pd.tnic>
 <78c99889-f175-f60f-716b-34a62203418a@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <78c99889-f175-f60f-716b-34a62203418a@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org

On Fri, Mar 17, 2017 at 12:03:31PM +0100, Paolo Bonzini wrote:

> If it is possible to do it in a fairly hypervisor-independent manner,
> I'm all for it.  That is, only by looking at AMD-specified CPUID leaves
> and at kernel ELF sections.

Not even that.

What that needs to be able to do is:

	kvm_map_percpu_hv_shared(st, sizeof(*st)))

where st is the percpu steal time ptr:

	struct kvm_steal_time *st = &per_cpu(steal_time, cpu);

Underneath, what it does basically is it clears the encryption mask from
the pte, see patch 16/32.

And I keep talking about SEV-ES because this is going to expand on the
need of having a shared memory region which the hypervisor and the guest
needs to access, thus unencrypted. See

http://support.amd.com/TechDocs/Protecting%20VM%20Register%20State%20with%20SEV-ES.pdf

This is where you come in and say what would be the best approach there...

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
