Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B83DC742A1
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 22:49:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 292682084B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 22:49:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="L5Z9krLK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 292682084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B17B08E00FF; Thu, 11 Jul 2019 18:49:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEF5B8E00DB; Thu, 11 Jul 2019 18:49:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DDB98E00FF; Thu, 11 Jul 2019 18:49:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 675938E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 18:49:22 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e20so4311650pfd.3
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 15:49:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0NNBSNCrFm9QFt/oHiBoXOjWFpu5BzIUnKEMn8Pl3Vo=;
        b=Fn5kcVcy2eag7Cd1IXNGlABPDUlth0NpF3f7u6GV9nkYiXJur6+dMCU1hEtmNV9pml
         63z6fILBhGMC2JaXIDn+C7icb7n6sk//u1qDVZdsm0/E421H+rE9DoMXc5BpCBccyfag
         S56u1g7yMSDNNnhV/oGPmPiG9WLmqdCVmkb/GWN7w+hI6zmwrBY5e9z8dz/WCvhLNgaS
         SPaAfW/IRtVlBcFNCtigeHnybEu+qqRAPiKQgaTpCRY3aUrGx62H4r/kuXTOBZd0hoyi
         krGuSuZsW6OTxxicvRGYJVisBX0/AsGUePjN5WZgcRAsQ1CWRunmLgVIPeOr13TR2X8A
         az+g==
X-Gm-Message-State: APjAAAUP5CDhGFT/NDL/blsBscWJYMKbkdt8Xez+zSVc+1VKjUuW3NC0
	yc+wU/ezeGVmjFuQ/iTt2OfIr4E2DUBC5xFulZqG6VHQtYc1YxwMM5jmc6J+BUG1lrSy+YnHIwL
	g7yJ2BOeCoKCeYAcqwA0BCUoU3PCsFWd3ggbdWgS00KqtMCKuaKjPmS0mTDKGUXGrDw==
X-Received: by 2002:a17:90a:d3d4:: with SMTP id d20mr7789665pjw.28.1562885361997;
        Thu, 11 Jul 2019 15:49:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTYatIY2Wy5mShmQHtnRkwwz5bJQVsr2XoeEsuJdxi7V3+bmSFTh6aWIrANgAdIwIbxKe1
X-Received: by 2002:a17:90a:d3d4:: with SMTP id d20mr7789604pjw.28.1562885360908;
        Thu, 11 Jul 2019 15:49:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562885360; cv=none;
        d=google.com; s=arc-20160816;
        b=hPU2gcRgeGNTVtuNE95tn9Y30jhaNnCvvpAok4BueSCT2/C0WCc85N5bRPs3IoEAUR
         YBnma1/oSP/Rzau6/BgOOXGW0e6rlQspyoyRkgQXC+l/t7Orw5J0Nan6L2cWG/k6EShV
         STraoM1D7L3MZO1IR1GoeX3ujlD9GX30kUR0xy8/u47B6UI5Hh3KZE20FRG66n07HNck
         yG+jUkpn88qejN5Q31Z4FnWHDJG3I8clWRgZK5eLpa48CMYZuje7m9kZ8Ai/XHAWzu6S
         11BZbn5mFpCj/Q8CsCu/1IQ2fHGfSw9BLtT5G2b/aWb9m50jCxCZ69Lq78BcBA2E1tZO
         2v4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0NNBSNCrFm9QFt/oHiBoXOjWFpu5BzIUnKEMn8Pl3Vo=;
        b=sGti1x7l0LjH9FT4iUvVHqjzY3aUgSc7HnMxiGTpd6RhMNtalCnkgt1evHZ7nZUvUJ
         8Swp+/05F70wu763aLBtcY7Rr2Do271f648XA+JOPokMLqPBThtwZABVuTI/HeUUVJ+P
         plzHgO+JOzUB8E7R/fgdfH+3/x9YEZ5YB+e4fpLbb24fFMz22uWxDIKnNeyCO/FpVFZY
         UamLiTuQbYXA+5yQQSrqdsu5DrmQc0HepYJNibNXeQFged+sD6opTbrB60ufKKZesqW6
         Fq9aVhZv+3X69NTSW1l+WC88Pz/m9LmNWovC4UY5ZqfR0HEneuiJ2dswKdEbdCnedBlA
         RPFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=L5Z9krLK;
       spf=pass (google.com: domain of mhiramat@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=mhiramat@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q2si6080375plh.59.2019.07.11.15.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 15:49:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhiramat@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=L5Z9krLK;
       spf=pass (google.com: domain of mhiramat@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=mhiramat@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from devnote2 (NE2965lan1.rev.em-net.ne.jp [210.141.244.193])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 08517214AF;
	Thu, 11 Jul 2019 22:49:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562885360;
	bh=F0692oM20SJBi7lipGMWh8asP30aK1zY5Sdre9epQkE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=L5Z9krLKI9nSy8tV3IzQalqBtpWXJWdMFlfaOUH+MjmcE0DMgIpRaPSkSpkAbMLkd
	 uYrReV24XpvMXXctVHHhCVZoyvjIhmkxGWE0i9pTGAjZZOKxa/jhEhzpyccUp6UubU
	 qBgK/iWqdautlONEQXJ6DpjMNy3+xr026DqMOj9E=
Date: Fri, 12 Jul 2019 07:49:07 +0900
From: Masami Hiramatsu <mhiramat@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Vineet Gupta <vgupta@synopsys.com>, Russell King
 <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will
 Deacon <will@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu
 <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, Paul Burton
 <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, Benjamin
 Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras
 <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Heiko Carstens
 <heiko.carstens@de.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian
 Borntraeger <borntraeger@de.ibm.com>, Yoshinori Sato
 <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S. Miller" <davem@davemloft.net>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov
 <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "Naveen N. Rao"
 <naveen.n.rao@linux.ibm.com>, Anil S Keshavamurthy
 <anil.s.keshavamurthy@intel.com>, Allison Randal <allison@lohutok.net>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Enrico Weigelt
 <info@metux.net>, Richard Fontana <rfontana@redhat.com>, Kate Stewart
 <kstewart@linuxfoundation.org>, Mark Rutland <mark.rutland@arm.com>, Andrew
 Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>,
 x86@kernel.org, linux-snps-arc@lists.infradead.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org
Subject: Re: [PATCH] mm/kprobes: Add generic kprobe_fault_handler() fallback
 definition
Message-Id: <20190712074907.1ab08841e77b6cc867396148@kernel.org>
In-Reply-To: <3aee1f30-241c-d1c2-2ff5-ff521db47755@arm.com>
References: <1562304629-29376-1-git-send-email-anshuman.khandual@arm.com>
	<20190705193028.f9e08fe9cf1ee86bc5c0bb82@kernel.org>
	<3aee1f30-241c-d1c2-2ff5-ff521db47755@arm.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Anshuman,

On Mon, 8 Jul 2019 09:03:13 +0530
Anshuman Khandual <anshuman.khandual@arm.com> wrote:

> >> Architectures like parisc enable CONFIG_KROBES without having a definition
> >> for kprobe_fault_handler() which results in a build failure.
> > 
> > Hmm, as far as I can see, kprobe_fault_handler() is closed inside each arch
> > specific code. The reason why include/linux/kprobes.h defines
> > dummy inline function is only for !CONFIG_KPROBES case.
> 
> IIRC Andrew mentioned [1] that we should remove this stub from the generic kprobes
> header because this is very much architecture specific. As we see in this proposed
> patch, except x86 there is no other current user which actually calls this from
> some where when CONFIG_KPROBES is not enabled.
> 
> [1] https://www.spinics.net/lists/linux-mm/msg182649.html

Ah, OK. I saw another branch. Also, this is a bugfix patch against
commit 4dd635bce90e ("mm, kprobes: generalize and rename notify_page_fault() as
 kprobe_page_fault()"), please add Fixes: tag on it.

In this case, we should just add a prototype of kprobe_fault_handler() in
include/linux/kprobes.h, and maybe add a stub of kprobe_fault_handler()
as a weak function, something like below.

int __weak kprobe_fault_handler(struct pt_regs *regs, int trapnr)
{
	/*
	 * Each architecture which uses kprobe_page_fault() must define
	 * a fault handler to handle page fault in kprobe correctly.
	 */
	WARN_ON_ONCE(1);
	return 0;
}

> >> Arch needs to
> >> provide kprobe_fault_handler() as it is platform specific and cannot have
> >> a generic working alternative. But in the event when platform lacks such a
> >> definition there needs to be a fallback.
> > 
> > Wait, indeed that each arch need to implement it, but that is for calling
> > kprobe->fault_handler() as user expected.
> > Hmm, why not fixing those architecture implementations?
> 
> After the recent change which introduced a generic kprobe_page_fault() every
> architecture enabling CONFIG_KPROBES must have a kprobe_fault_handler() which
> was not the case earlier.

As far as I can see, gcc complains it because there is no prototype of
kprobe_fault_handler(). Actually no need to define empty kprobe_fault_handler()
on each arch. If we have a prototype, but no actual function, gcc stops the
error unless the arch depending code uses it. So actually, we don't need above
__weak function.

> Architectures like parisc which does enable KPROBES but
> never used (kprobe_page_fault or kprobe->fault_handler) kprobe_fault_handler() now
> needs one as well.

(Hmm, it sounds like the kprobes porting is incomplete on parisc...)

> I am not sure and will probably require inputs from arch parsic
> folks whether it at all needs one. We dont have a stub or fallback definition for
> kprobe_fault_handler() when CONFIG_KPROBES is enabled just to prevent a build
> failure in such cases.

Yeah, that is a bug, and fixed by adding a prototype, not introducing new macro.

> 
> In such a situation it might be better defining a stub symbol fallback than to try
> to implement one definition which the architecture previously never needed or used.
> AFAICS there is no generic MM callers for kprobe_fault_handler() as well which would
> have made it mandatory for parisc to define a real one.
> 
> > 
> >> This adds a stub kprobe_fault_handler() definition which not only prevents
> >> a build failure but also makes sure that kprobe_page_fault() if called will
> >> always return negative in absence of a sane platform specific alternative.
> > 
> > I don't like introducing this complicated macro only for avoiding (not fixing)
> > build error. To fix that, kprobes on parisc should implement kprobe_fault_handler
> > correctly (and call kprobe->fault_handler).
> 
> As I mentioned before parsic might not need a real one. But you are right this
> complicated (if perceived as such) change can be just avoided at least for the
> build failure problem by just defining a stub definition kprobe_fault_handler()
> for arch parsic when CONFIG_KPROBES is enabled. But this patch does some more
> and solves the kprobe_fault_handler() symbol dependency in a more generic way and
> forces kprobe_page_fault() to fail in absence a real arch kprobe_fault_handler().
> Is not it worth solving in this way ?
> 
> > 
> > BTW, even if you need such generic stub, please use a weak function instead
> > of macros for every arch headers.
> 
> There is a bit problem with that. The existing definitions are with different
> signatures and an weak function will need them to be exact same for override
> requiring more code changes. Hence choose to go with a macro in each header.
> 
> arch/arc/include/asm/kprobes.h:int kprobe_fault_handler(struct pt_regs *regs, unsigned long cause);
> arch/arm/include/asm/kprobes.h:int kprobe_fault_handler(struct pt_regs *regs, unsigned int fsr);
> arch/arm64/include/asm/kprobes.h:int kprobe_fault_handler(struct pt_regs *regs, unsigned int fsr);
> arch/ia64/include/asm/kprobes.h:extern int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
> arch/powerpc/include/asm/kprobes.h:extern int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
> arch/s390/include/asm/kprobes.h:int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
> arch/sh/include/asm/kprobes.h:extern int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
> arch/sparc/include/asm/kprobes.h:int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
> arch/x86/include/asm/kprobes.h:extern int kprobe_fault_handler(struct pt_regs *regs, int trapnr);

OK, in that case, original commit is wrong way. it should be reverted and
should introduce something like below


/* Returns true if arch should call kprobes_fault_handler() */
static nokprobe_inline bool is_kprobe_page_fault(struct pt_regs *regs)
{
	if (!kprobes_built_in())
		return false;
	if (user_mode(regs))
		return false;
	/*
	 * To be potentially processing a kprobe fault and to be allowed
	 * to call kprobe_running(), we have to be non-preemptible.
	 */
	if (preemptible())
		return false;
	if (!kprobe_running())
		return false;
	return true;
}

Since it silently casts the type of trapnr, which is strongly depends
on architecture.

> >> While here wrap kprobe_page_fault() in CONFIG_KPROBES. This enables stud
> >> definitions for generic kporbe_fault_handler() and kprobes_built_in() can
> >> just be dropped. Only on x86 it needs to be added back locally as it gets
> >> used in a !CONFIG_KPROBES function do_general_protection().
> > 
> > If you want to remove kprobes_built_in(), you should replace it with
> > IS_ENABLED(CONFIG_KPROBES), instead of this...
> 
> Apart from kprobes_built_in() the intent was to remove !CONFIG_KPROBES
> stub for kprobe_fault_handler() as well which required making generic
> kprobe_page_fault() to be empty in such case.

No, I meant that "IS_ENABLED(CONFIG_KPROBES)" is generic and is equal to
what kprobes_built_in() does.

Thank you,

-- 
Masami Hiramatsu <mhiramat@kernel.org>

