Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE0F6B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 11:21:35 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 46so6122691qtu.18
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 08:21:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v42si6435494qta.232.2017.03.29.08.21.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 08:21:34 -0700 (PDT)
Subject: Re: [RFC PATCH v2 16/32] x86: kvm: Provide support to create Guest
 and HV shared per-CPU variables
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846773666.2349.9492983018843773590.stgit@brijesh-build-machine>
 <20170328183931.rqorduu5fnp5r3y2@pd.tnic>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <9a8723fc-300d-eb76-deb1-cbc8492e9d49@redhat.com>
Date: Wed, 29 Mar 2017 17:21:13 +0200
MIME-Version: 1.0
In-Reply-To: <20170328183931.rqorduu5fnp5r3y2@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>, Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, davem@davemloft.net



On 28/03/2017 20:39, Borislav Petkov wrote:
>> 2) Since the encryption attributes works on PAGE_SIZE hence add some extra
>> padding to 'struct kvm-steal-time' to make it PAGE_SIZE and then at runtime
>> clear the encryption attribute of the full PAGE. The downside of this was
>> now we need to modify structure which may break the compatibility.
> From SEV-ES whitepaper:
> 
> "To facilitate this communication, the SEV-ES architecture defines
> a Guest Hypervisor Communication Block (GHCB). The GHCB resides in
> page of shared memory so it is accessible to both the guest VM and the
> hypervisor."
> 
> So this is kinda begging to be implemented with a shared page between
> guest and host. And then put steal-time, ... etc in there too. Provided
> there's enough room in the single page for the GHCB *and* our stuff.

The GHCB would have to be allocated much earlier, possibly even by
firmware depending on how things will be designed.  I think it's
premature to consider SEV-ES requirements.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
