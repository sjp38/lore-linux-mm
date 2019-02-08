Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E046EC169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 21:31:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98F56218DA
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 21:31:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98F56218DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 393F88E00A2; Fri,  8 Feb 2019 16:31:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 344CA8E00A1; Fri,  8 Feb 2019 16:31:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E5EC8E00A2; Fri,  8 Feb 2019 16:31:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB7258E00A1
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 16:31:38 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id p20so3615131plr.22
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 13:31:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hVhJ4UE5uFoGSJAxbdZGO2DFN6y55pNwLioTEV6IVgg=;
        b=bgsKgAA4x3iXYwNrDzR2WIwHzBjMuEHtP2vQJwL/xaX38xBnpsjT61iDP2ZdvZk7r2
         A19Q1cp88hzkjOB+Emf5OU8HjPzqM33wR91nqEkFAbH9F8XjGfgHq/ZnuIb1m55QCEbw
         c9P52hBya0O/v5dc6HS7TwM97HRL3OtJ0HF6JOtqK5IWAKSa5bWhdafowOjjZPs4ycdP
         NXIOr0GkH6UTD2T7Bmhah7Y3E3SRRXRXtWd4axE8YncpUM9ekIw/perrFkvcdsci8miE
         2T1yNibpuYbcTRU33eOJiQWzFRwm6IUe38BCqsY+m0xWgpE4/0CmTv1i4GlSR/bArjMT
         6myQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAub+ImYBaVGJu1bXcbEq82fXIjJ3ovIsw/mfcIZAfCwCaVoFi43r
	gqA9WdbwOoQZ3CkYFK5xEnjnEDZ1mAJogqg8budi0relG1z3Li5MGZNc+VbkAsNjjUm3+8J9nWF
	grEkU12DarFyYUjWotA6Fi/AGTJP2NYB1mEbeGM8uIa+yDJ26xbjF8pwwPUAqOwSvlQ==
X-Received: by 2002:a17:902:9a9:: with SMTP id 38mr24650237pln.204.1549661498486;
        Fri, 08 Feb 2019 13:31:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYgYr5lqVqRlK0s+HzLLRzLLw6ST0ksheQeXjC5h04MmrsxgIU9zo6ZJwEqQhhBKjfDvARq
X-Received: by 2002:a17:902:9a9:: with SMTP id 38mr24650177pln.204.1549661497638;
        Fri, 08 Feb 2019 13:31:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549661497; cv=none;
        d=google.com; s=arc-20160816;
        b=PFKEEmtglOfatkS58gFey/r/oc6rYdgcw/KfElkB9k+/owGDBHtSf/5MsVFtBUUH8g
         BYqLIcQM/QGMyWR88B7B8XqKlvBpKez6VAB+f6VzpavOS74uFJO+MQOxKuLIsiaP9sIh
         yKCgpmGH5YO+dIsLYTu90zbRxM20bBFbI14dXEZmP2V4CnzyJV9wSlVPGXVyycAxAgi0
         4sdPLVucdOmPWWgMR0ZqZivRIkdMWjpPvhkCFztFueDacV8l2s5P1wY6OdTmkk7yYjnA
         YGzS2SGSLZWq5e1/BzVk066ERuOtqtkQ9n2ZFWJo53kdxFeye/wl5kglw+ri0A4UPTC2
         GjVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=hVhJ4UE5uFoGSJAxbdZGO2DFN6y55pNwLioTEV6IVgg=;
        b=vlrgjJTzFIHg8CweexaKF2O6JxlmXiEg7T9m6m9hrf0cwKHMuJkc/ae4imkuuI0/I6
         t7nmtBXkhKh5Wh5sEwVZPna42K0RsxoDQHM/Wa+a982kWSY0zjvBV7S133EHH3dfJ00d
         CLjmtCaGpnIzmjyqWgHwHp/Br6Bn7ogsj0F0B7B4inGnmPedUGW0NXF0Km4LbOFbG+Vq
         XePbN94YFHCHZvCg6dNxgtqqYdDfd2DDE+Y197bKdQkCTsOHs/ZyEq+7f5esH4JZgtYt
         8EP7btb44DfEt3FE48c0AMFTd5K0CUJPtpjHgMI0KcN4eCV+mnDAoZZyEHZNQTyp09Yh
         9IVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b5si2955841pgw.377.2019.02.08.13.31.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 13:31:37 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Feb 2019 13:31:37 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,348,1544515200"; 
   d="scan'208";a="137020789"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga001.jf.intel.com with ESMTP; 08 Feb 2019 13:31:36 -0800
Message-ID: <e6c9ec462b50f2d6a33416e16b42d995236e447e.camel@linux.intel.com>
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory
 hints
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>, Luiz Capitulino
	 <lcapitulino@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, 
 rkrcmar@redhat.com, x86@kernel.org, mingo@redhat.com, bp@alien8.de,
 hpa@zytor.com,  pbonzini@redhat.com, tglx@linutronix.de,
 akpm@linux-foundation.org
Date: Fri, 08 Feb 2019 13:31:36 -0800
In-Reply-To: <5f5c03ac-0d21-d92b-1772-f26773437019@redhat.com>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
	 <20190204181552.12095.46287.stgit@localhost.localdomain>
	 <20190207132104.17a296da@doriath>
	 <34c93e5a05a7dc93e38364733f8832f2e1b2dcb3.camel@linux.intel.com>
	 <5f5c03ac-0d21-d92b-1772-f26773437019@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-02-08 at 16:05 -0500, Nitesh Narayan Lal wrote:
> On 2/7/19 1:44 PM, Alexander Duyck wrote:
> > On Thu, 2019-02-07 at 13:21 -0500, Luiz Capitulino wrote:
> > > On Mon, 04 Feb 2019 10:15:52 -0800
> > > Alexander Duyck <alexander.duyck@gmail.com> wrote:
> > > 
> > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > 
> > > > Add guest support for providing free memory hints to the KVM hypervisor for
> > > > freed pages huge TLB size or larger. I am restricting the size to
> > > > huge TLB order and larger because the hypercalls are too expensive to be
> > > > performing one per 4K page. Using the huge TLB order became the obvious
> > > > choice for the order to use as it allows us to avoid fragmentation of higher
> > > > order memory on the host.
> > > > 
> > > > I have limited the functionality so that it doesn't work when page
> > > > poisoning is enabled. I did this because a write to the page after doing an
> > > > MADV_DONTNEED would effectively negate the hint, so it would be wasting
> > > > cycles to do so.
> > > > 
> > > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > ---
> > > >  arch/x86/include/asm/page.h |   13 +++++++++++++
> > > >  arch/x86/kernel/kvm.c       |   23 +++++++++++++++++++++++
> > > >  2 files changed, 36 insertions(+)
> > > > 
> > > > diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
> > > > index 7555b48803a8..4487ad7a3385 100644
> > > > --- a/arch/x86/include/asm/page.h
> > > > +++ b/arch/x86/include/asm/page.h
> > > > @@ -18,6 +18,19 @@
> > > >  
> > > >  struct page;
> > > >  
> > > > +#ifdef CONFIG_KVM_GUEST
> > > > +#include <linux/jump_label.h>
> > > > +extern struct static_key_false pv_free_page_hint_enabled;
> > > > +
> > > > +#define HAVE_ARCH_FREE_PAGE
> > > > +void __arch_free_page(struct page *page, unsigned int order);
> > > > +static inline void arch_free_page(struct page *page, unsigned int order)
> > > > +{
> > > > +	if (static_branch_unlikely(&pv_free_page_hint_enabled))
> > > > +		__arch_free_page(page, order);
> > > > +}
> > > > +#endif
> > > > +
> > > >  #include <linux/range.h>
> > > >  extern struct range pfn_mapped[];
> > > >  extern int nr_pfn_mapped;
> > > > diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
> > > > index 5c93a65ee1e5..09c91641c36c 100644
> > > > --- a/arch/x86/kernel/kvm.c
> > > > +++ b/arch/x86/kernel/kvm.c
> > > > @@ -48,6 +48,7 @@
> > > >  #include <asm/tlb.h>
> > > >  
> > > >  static int kvmapf = 1;
> > > > +DEFINE_STATIC_KEY_FALSE(pv_free_page_hint_enabled);
> > > >  
> > > >  static int __init parse_no_kvmapf(char *arg)
> > > >  {
> > > > @@ -648,6 +649,15 @@ static void __init kvm_guest_init(void)
> > > >  	if (kvm_para_has_feature(KVM_FEATURE_PV_EOI))
> > > >  		apic_set_eoi_write(kvm_guest_apic_eoi_write);
> > > >  
> > > > +	/*
> > > > +	 * The free page hinting doesn't add much value if page poisoning
> > > > +	 * is enabled. So we only enable the feature if page poisoning is
> > > > +	 * no present.
> > > > +	 */
> > > > +	if (!page_poisoning_enabled() &&
> > > > +	    kvm_para_has_feature(KVM_FEATURE_PV_UNUSED_PAGE_HINT))
> > > > +		static_branch_enable(&pv_free_page_hint_enabled);
> > > > +
> > > >  #ifdef CONFIG_SMP
> > > >  	smp_ops.smp_prepare_cpus = kvm_smp_prepare_cpus;
> > > >  	smp_ops.smp_prepare_boot_cpu = kvm_smp_prepare_boot_cpu;
> > > > @@ -762,6 +772,19 @@ static __init int kvm_setup_pv_tlb_flush(void)
> > > >  }
> > > >  arch_initcall(kvm_setup_pv_tlb_flush);
> > > >  
> > > > +void __arch_free_page(struct page *page, unsigned int order)
> > > > +{
> > > > +	/*
> > > > +	 * Limit hints to blocks no smaller than pageblock in
> > > > +	 * size to limit the cost for the hypercalls.
> > > > +	 */
> > > > +	if (order < KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER)
> > > > +		return;
> > > > +
> > > > +	kvm_hypercall2(KVM_HC_UNUSED_PAGE_HINT, page_to_phys(page),
> > > > +		       PAGE_SIZE << order);
> > > 
> > > Does this mean that the vCPU executing this will get stuck
> > > here for the duration of the hypercall? Isn't that too long,
> > > considering that the zone lock is taken and madvise in the
> > > host block on semaphores?
> > 
> > I'm pretty sure the zone lock isn't held when this is called. The lock
> > isn't acquired until later in the path. This gets executed just before
> > the page poisoning call which would take time as well since it would
> > have to memset an entire page. This function is called as a part of
> > free_pages_prepare, the zone locks aren't acquired until we are calling
> > into either free_one_page and a few spots before calling
> > __free_one_page.
> > 
> > My other function in patch 4 which does this from inside of
> > __free_one_page does have to release the zone lock since it is taken
> > there.
> > 
> 
> Considering hypercall's are costly, will it not make sense to coalesce
> the pages you are reporting and make a single hypercall for a bunch of
> pages?

That is what I am doing with this code and patch 4. I am only making
the call when I have been given a page that is 2M or larger. As such I
am only making one hypercall for every 512 4K pages.

So for example on my test VMs with 8G of RAM I see only about 3K calls
when it ends up freeing all of the application memory which is about 6G
after my test has ended.

