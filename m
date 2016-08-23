Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9CA346B0069
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 03:15:45 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id x131so29642412ite.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 00:15:45 -0700 (PDT)
Received: from helcar.hengli.com.au (helcar.hengli.com.au. [209.40.204.226])
        by mx.google.com with ESMTPS id g76si2732702ioe.130.2016.08.23.00.15.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 23 Aug 2016 00:15:42 -0700 (PDT)
Date: Tue, 23 Aug 2016 15:14:58 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH v1 18/28] crypto: add AMD Platform Security Processor
 driver
Message-ID: <20160823071458.GC392@gondor.apana.org.au>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190844204.9523.14931918358168729826.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <147190844204.9523.14931918358168729826.stgit@brijesh-build-machine>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

On Mon, Aug 22, 2016 at 07:27:22PM -0400, Brijesh Singh wrote:
> The driver to communicate with Secure Encrypted Virtualization (SEV)
> firmware running within the AMD secure processor providing a secure key
> management interface for SEV guests.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>

This driver doesn't seem to hook into the Crypto API at all, is
there any reason why it should be in drivers/crypto?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
