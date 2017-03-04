Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5DFA76B0038
	for <linux-mm@kvack.org>; Sat,  4 Mar 2017 05:11:33 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id l37so47799665wrc.7
        for <linux-mm@kvack.org>; Sat, 04 Mar 2017 02:11:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c46si18209424wra.299.2017.03.04.02.11.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 04 Mar 2017 02:11:31 -0800 (PST)
Date: Sat, 4 Mar 2017 11:11:13 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v2 01/32] x86: Add the Secure Encrypted
 Virtualization CPU feature
Message-ID: <20170304101113.k6ontjjbljanm6tv@pd.tnic>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846752953.2349.17505492128445909591.stgit@brijesh-build-machine>
 <20170303165915.3233fx7wo74vsslx@pd.tnic>
 <404fafd8-bbd6-b8c7-1abb-787ac083ea41@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <404fafd8-bbd6-b8c7-1abb-787ac083ea41@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

On Fri, Mar 03, 2017 at 03:01:23PM -0600, Brijesh Singh wrote:
> +merely enables SME (sets bit 23 of the MSR_K8_SYSCFG), then Linux can
> activate
> +memory encryption by default (CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT=y)
> or
> +by supplying mem_encrypt=on on the kernel command line.  However, if BIOS
> does
> +not enable SME, then Linux will not be able to activate memory encryption,
> even
> +if configured to do so by default or the mem_encrypt=on command line
> parameter
> +is specified.

This looks like a wraparound...

$ test-apply.sh /tmp/brijesh.singh.delta
checking file Documentation/admin-guide/kernel-parameters.txt
Hunk #1 succeeded at 2144 (offset -9 lines).
checking file Documentation/x86/amd-memory-encryption.txt
patch: **** malformed patch at line 23: DRAM from physical

Yap.

Looks like exchange or your mail client decided to do some patch editing
on its own.

Please send it to yourself first and try applying.

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
