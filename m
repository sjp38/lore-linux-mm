Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8EF426B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 08:03:00 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u191so50517060oie.3
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 05:03:00 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0066.outbound.protection.outlook.com. [104.47.37.66])
        by mx.google.com with ESMTPS id x132si6351091oig.71.2016.08.24.05.02.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 Aug 2016 05:02:46 -0700 (PDT)
Subject: Re: [RFC PATCH v1 18/28] crypto: add AMD Platform Security Processor
 driver
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190844204.9523.14931918358168729826.stgit@brijesh-build-machine>
 <20160823071458.GC392@gondor.apana.org.au>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <a5180201-7a44-2148-26ba-4e06bbfd4e3a@amd.com>
Date: Wed, 24 Aug 2016 07:02:26 -0500
MIME-Version: 1.0
In-Reply-To: <20160823071458.GC392@gondor.apana.org.au>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Herbert Xu <herbert@gondor.apana.org.au>, Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net



On 08/23/2016 02:14 AM, Herbert Xu wrote:
> On Mon, Aug 22, 2016 at 07:27:22PM -0400, Brijesh Singh wrote:
>> The driver to communicate with Secure Encrypted Virtualization (SEV)
>> firmware running within the AMD secure processor providing a secure key
>> management interface for SEV guests.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
> 
> This driver doesn't seem to hook into the Crypto API at all, is
> there any reason why it should be in drivers/crypto?

Yes, this needs to be cleaned up.  The PSP and the CCP share the same
PCI id, so this has to be integrated with the CCP. It could either
be moved into the drivers/crypto/ccp directory or both the psp and
ccp device specific support can be moved somewhere else leaving just
the ccp crypto API related files in drivers/crypto/ccp.

Thanks,
Tom

> 
> Thanks,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
