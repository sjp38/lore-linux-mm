Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1751D6B0038
	for <linux-mm@kvack.org>; Sat, 18 Mar 2017 12:37:19 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y51so18815980wry.6
        for <linux-mm@kvack.org>; Sat, 18 Mar 2017 09:37:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e5si15624275wrd.173.2017.03.18.09.37.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 18 Mar 2017 09:37:17 -0700 (PDT)
Date: Sat, 18 Mar 2017 17:37:06 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v2 14/32] x86: mm: Provide support to use memblock
 when spliting large pages
Message-ID: <20170318163706.GB4231@nazgul.tnic>
References: <20170310110657.hophlog2juw5hpzz@pd.tnic>
 <cb6a9a56-2c52-d98d-3ff6-3b61d0e5875e@amd.com>
 <20170316182836.tyvxoeq56thtc4pd@pd.tnic>
 <ec134379-6a48-905c-26e4-f6f2738814dc@redhat.com>
 <20170317101737.icdois7sdmtutt6b@pd.tnic>
 <b6f9f46c-58c4-a19c-4955-2d07bd411443@redhat.com>
 <20170317105610.musvo4baokgssvye@pd.tnic>
 <78c99889-f175-f60f-716b-34a62203418a@redhat.com>
 <20170317113337.syvpat3c4s2l4nuz@pd.tnic>
 <b516a873-029a-b20a-3c43-d8bf4a200cb7@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b516a873-029a-b20a-3c43-d8bf4a200cb7@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org

On Fri, Mar 17, 2017 at 03:45:26PM +0100, Paolo Bonzini wrote:
> Yes, and I'd like that to be done with a new data section rather than a
> special KVM hook.

Can you give more details about how pls? Or is there already an example for that
somewhere in the kvm code?

> I have no idea.  SEV-ES seems to be very hard to set up at the beginning
> of the kernel bootstrap.  There's all sorts of chicken and egg problems,
> as well as complicated handshakes between the firmware and the guest,
> and the way to do it also depends on the trust and threat models.
> 
> A much simpler way is to just boot under a trusted hypervisor, do
> "modprobe sev-es" and save a snapshot of the guest.  Then you sign the
> snapshot and pass it to your cloud provider.

Right, especially the early trapping could be a pain. I don't think this
is cast in stone yet, though...

We'll see.

Thanks.

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
