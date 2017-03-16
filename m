Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0876B0389
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 18:25:43 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g8so605592wmg.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 15:25:43 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id q6si2662369wrc.328.2017.03.16.15.25.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 15:25:42 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id u108so7567076wrb.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 15:25:41 -0700 (PDT)
Subject: Re: [RFC PATCH v2 14/32] x86: mm: Provide support to use memblock
 when spliting large pages
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846771545.2349.9373586041426414252.stgit@brijesh-build-machine>
 <20170310110657.hophlog2juw5hpzz@pd.tnic>
 <cb6a9a56-2c52-d98d-3ff6-3b61d0e5875e@amd.com>
 <20170316182836.tyvxoeq56thtc4pd@pd.tnic>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <ec134379-6a48-905c-26e4-f6f2738814dc@redhat.com>
Date: Thu, 16 Mar 2017 23:25:36 +0100
MIME-Version: 1.0
In-Reply-To: <20170316182836.tyvxoeq56thtc4pd@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>, Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedo.kvack.org



On 16/03/2017 19:28, Borislav Petkov wrote:
> So how hard would it be if the hypervisor allocated that memory for the
> guest instead? It would allocate it decrypted and guest would need to
> access it decrypted too. All in preparation for SEV-ES which will need a
> block of unencrypted memory for the guest anyway...

The kvmclock memory is initially zero so there is no need for the
hypervisor to allocate anything; the point of these patches is just to
access the data in a natural way from Linux source code.

I also don't really like the patch as is (plus it fails modpost), but
IMO reusing __change_page_attr and __split_large_page is the right thing
to do.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
