Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB993C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:04:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8717D2133D
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:04:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="N2gTptqw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8717D2133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37FA06B000A; Thu, 13 Jun 2019 16:04:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 308DC8E0002; Thu, 13 Jun 2019 16:04:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AC266B000D; Thu, 13 Jun 2019 16:04:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D5D686B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:04:11 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a5so201706pla.3
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:04:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lhY/dH1LxkksLu5i0IWkS7fg7law7uuNa/mS/dgjQ4Q=;
        b=Aj183lGl04289qJ3MKtgXFYNcgh2lnMtaqQHn09BHj+OPW6oQH4QP6/FTopamp5sc/
         vg7rYKHxKlkSjx4GNlDTUpm7N2wIExCxM+pzPEbaMsqTkGJH0vZpBaK8YAeY52Ylaa2H
         nyA0OCYNp0Scpcwhaw3grA4YA83y75J1qhbx8jJa5WtEa2Ljbk6qfoYwqgLdwwaLDNxt
         sSrEFotTcNVsRYEz3AGbfKhW0tAzJli/ovykKRJizaOcJhEb0QOcLmPbeg/RbPwlV2cP
         1Qeu8olkby0782DaVqu+8Ket5aRJI0AigkYZGSXGwehffJXJYcHBM0SiTc4+IYIO5fQd
         sblA==
X-Gm-Message-State: APjAAAVumu2luouujJnVOOfhrbArfPkASTM0YcqNfquUk6barjQxKbgg
	vHyXiIbh+uMSuP3LGJRYCjY1BkrPSI/PmExM8VCx2BEo/AorTMBgObn83hNBAn47kaRpteR5m4s
	ES3EEWVyDbhN5bZmw0TDl+sJToCxkeFFzbgwjdDgFTM8Bxm+wGMIk8jJmbITiin98/w==
X-Received: by 2002:a65:63c3:: with SMTP id n3mr12056582pgv.139.1560456251433;
        Thu, 13 Jun 2019 13:04:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzF+9TiQ5OAZTfzN8K539iRxLGffb7YchVHD2hSxEmGZQE8dWAXBWaWAUz50OxxfytfoKKZ
X-Received: by 2002:a65:63c3:: with SMTP id n3mr12056524pgv.139.1560456250725;
        Thu, 13 Jun 2019 13:04:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560456250; cv=none;
        d=google.com; s=arc-20160816;
        b=NskOZmMIEaLX7ICusNlGRnFot9JgebJ69BTk6B8vkRzGpeiY4qLQ1yUqOT8vBGKyRN
         TBsovUSnIFVW+at1YmndF+/wOVkb6a0j6gBLiBQSyzFhE/4Vu1mjTW2gxE9pa3OwWP7+
         sdpSJFJ3M1ZPUsdxZzACP3zchEqt0sBRa/rCuy8umG0qEckcMo5Mywfguc1zUYQTZia/
         8Y8/dyZLkmqeCe512sIvSRXiM+VH3xStMvBMmu9/WZjvCb21VSmJihocdnwkzvOwJoGv
         laVMAKDj2H/Iv5lNwWqfxIBD9/PLvOe6qZmRaUSBG847BcHNFr+3gtlfITDpx3ssMwoz
         liig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lhY/dH1LxkksLu5i0IWkS7fg7law7uuNa/mS/dgjQ4Q=;
        b=ABC7W1VF1/366UvDPE12QQhhKNL8wWPkSCSuLqVUzpmnnSpOmCZ53avmQ6ux/KmDrL
         JO7q2/OB/LVGuDavrJW2O/jAvClzzTVb4OvfJETU0rZU+tOp5/Ypulhq33CPMhgRc8sM
         RO7npEtwjb4TwHaVJ4zmpCvHpFfkbmzEIFZRkHpAbgQl8/srohUTWf3oFDpIzYofzSn2
         tODQ7piTZ9FELZ6nanashcA4peQprdm9HK4LjYQu79eBskCUmgff46uJr9N9Zd1q/UZf
         SzOuW8e13aLPjLtdeiE84cvgjuJLyjXsBFJWue3EmXUDCj4s1RYl+cxVwa9orXoIXUdX
         j8hg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=N2gTptqw;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i4si394068pfa.218.2019.06.13.13.04.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 13:04:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=N2gTptqw;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1E84021537;
	Thu, 13 Jun 2019 20:04:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560456250;
	bh=STyJgmmKr944RjOkqQ8HWC3xeSyqe7HVqnGI2LWRsD8=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=N2gTptqwNshky9t39zHrhF/tFwNwxgbkrbTJor+tak1vLqX97uKewRk8bUnzrn4Ko
	 U5IaH0MfRPlK77bT7Yc/4PbSrlc3n6J8M0GsjcRBoXIwR5bmuZZez1tgkNHDFM277/
	 c+zGeW7mHjTeucDkGZEHLB7VbopRA5mQ7/vZdAH4=
Date: Thu, 13 Jun 2019 13:04:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-snps-arc@lists.infradead.org, linux-mips@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, Mark
 Rutland <mark.rutland@arm.com>, Christophe Leroy <christophe.leroy@c-s.fr>,
 Stephen Rothwell <sfr@canb.auug.org.au>, Andrey Konovalov
 <andreyknvl@google.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul
 Mackerras <paulus@samba.org>, Russell King <linux@armlinux.org.uk>, Catalin
 Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony
 Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Martin
 Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens
 <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>,
 "David S. Miller" <davem@davemloft.net>, Thomas Gleixner
 <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar
 <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, Dave Hansen
 <dave.hansen@linux.intel.com>, Vineet Gupta <vgupta@synopsys.com>, James
 Hogan <jhogan@kernel.org>, Paul Burton <paul.burton@mips.com>, Ralf Baechle
 <ralf@linux-mips.org>
Subject: Re: [PATCH] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
Message-Id: <20190613130408.3091869d8e50d0524157523f@linux-foundation.org>
In-Reply-To: <1560420444-25737-1-git-send-email-anshuman.khandual@arm.com>
References: <1560420444-25737-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jun 2019 15:37:24 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:

> Architectures which support kprobes have very similar boilerplate around
> calling kprobe_fault_handler(). Use a helper function in kprobes.h to unify
> them, based on the x86 code.
> 
> This changes the behaviour for other architectures when preemption is
> enabled. Previously, they would have disabled preemption while calling the
> kprobe handler. However, preemption would be disabled if this fault was
> due to a kprobe, so we know the fault was not due to a kprobe handler and
> can simply return failure.
> 
> This behaviour was introduced in the commit a980c0ef9f6d ("x86/kprobes:
> Refactor kprobes_fault() like kprobe_exceptions_notify()")
> 
> ...
>
> --- a/arch/arm/mm/fault.c
> +++ b/arch/arm/mm/fault.c
> @@ -30,28 +30,6 @@
>  
>  #ifdef CONFIG_MMU
>  
> -#ifdef CONFIG_KPROBES
> -static inline int notify_page_fault(struct pt_regs *regs, unsigned int fsr)

Some architectures make this `static inline'.  Others make it
`nokprobes_inline', others make it `static inline __kprobes'.  The
latter seems weird - why try to put an inline function into
.kprobes.text?

So..  what's the best thing to do here?  You chose `static
nokprobe_inline' - is that the best approach, if so why?  Does
kprobe_page_fault() actually need to be inlined?

Also, some architectures had notify_page_fault returning int, others
bool.  You chose bool and that seems appropriate and all callers are OK
with that.

