Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B53446B03A8
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 09:00:03 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id x66so116558098pfb.2
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 06:00:03 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id q75si10698243pgq.363.2017.03.03.06.00.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 06:00:02 -0800 (PST)
Message-ID: <1488549318.20145.76.camel@linux.intel.com>
Subject: Re: [RFC PATCH v2 19/32] crypto: ccp: Introduce the AMD Secure
 Processor device
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Fri, 03 Mar 2017 15:55:18 +0200
In-Reply-To: <0db0055f-9208-524f-74aa-674894ee90d3@amd.com>
References: 
	<148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
	 <148846777589.2349.11698765767451886038.stgit@brijesh-build-machine>
	 <20170302173936.GC11970@leverpostej>
	 <0db0055f-9208-524f-74aa-674894ee90d3@amd.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>, Mark Rutland <mark.rutland@arm.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

On Thu, 2017-03-02 at 13:11 -0600, Brijesh Singh wrote:
> Hi Mark,
> 
> On 03/02/2017 11:39 AM, Mark Rutland wrote:
> > On Thu, Mar 02, 2017 at 10:16:15AM -0500, Brijesh Singh wrote:

> > > 
> > > +ccp-$(CONFIG_CRYPTO_DEV_CCP) += ccp-dev.o \
> > > A 	A A A A ccp-ops.o \
> > > A 	A A A A ccp-dev-v3.o \
> > > A 	A A A A ccp-dev-v5.o \
> > > -	A A A A ccp-platform.o \
> > > A 	A A A A ccp-dmaengine.o
> > 
> > It looks like ccp-platform.c has morphed into sp-platform.c (judging
> > by
> > the compatible string and general shape of the code), and the
> > original
> > ccp-platform.c is no longer built.
> > 
> > Shouldn't ccp-platform.c be deleted by this patch?
> > 
> 
> Good catch. Both ccp-platform.c and ccp-pci.c should have been
> deletedA 
> by this patch. I missed deleting it, will fix in next rev.

Don't forget to use -M -C when preparing / sending patches.

-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
