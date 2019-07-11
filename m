Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D26DC74A51
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 09:57:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5197821019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 09:57:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5197821019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D824B8E00B0; Thu, 11 Jul 2019 05:57:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D0B908E0032; Thu, 11 Jul 2019 05:57:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B859B8E00B0; Thu, 11 Jul 2019 05:57:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 641418E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 05:57:50 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z20so4147377edr.15
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 02:57:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Qu0p3hBJIS1tt+CwL8iHr3VvkzVSz5VHHFsNUQJfq4A=;
        b=Pr5zlGAZIxx1PB8F0icbSNjHw0l6Qd53nR6MxlGPjTS/u4g7Njs/RvOCJ8mSQgOPk7
         PM0I5Q+qFTHxDVI2CfKqgN/SJUJF4oxdtIlt2jr2bABYWbFXN0Rl443yDN283nL5Iofv
         MaZl2cVTn9USyHDfATHCvxoMda+9lbEKYsCJN0kNnVD3irltEhy4kZ8az15P6ftGuEFo
         q1DsT0IMbs9229FJU3emf+Su/FOry2v92JyAo8QBhdpLp1N8a6ArMLy0NLmDFu2LVN5d
         inKS+oSWxiYnzYRStd9CpY53S9rxCdu9uuW9woGb2ZBDMagIFz+SaE0MYQM3KtsjPVS5
         wRtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVrKTbqaP579dY8YQhMKbFcKCosZTRuL5IbcyOi4DSs6GuMbH1F
	193H9tCm71yiqJJy6NiJdpOoxPS56C115zND93irqZ9GrWEZmt+uOBiFIRO0sPgfG13lZ0+MfXR
	dA5NT+eCcG8hEtHF/fvWzuJsjpR9OyIxB8tFX7cDHF8fsRTI1Og0LPnlK3wSd58zgUg==
X-Received: by 2002:aa7:d058:: with SMTP id n24mr2443173edo.143.1562839069968;
        Thu, 11 Jul 2019 02:57:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3zAwJSRRipQqvOwHEFflmpsJCQsj4YwRk/rzYsUW2nmZ3FtnDyOhMbf2qXCU1bg4qfmF5
X-Received: by 2002:aa7:d058:: with SMTP id n24mr2443126edo.143.1562839069068;
        Thu, 11 Jul 2019 02:57:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562839069; cv=none;
        d=google.com; s=arc-20160816;
        b=jdk2mn4D05zlDxjW2HYqs01KlYz0g/W3HafREmb911W3ONHzbXZ+riQvjHdFayR2xq
         yUH60XX/gOFkpB1jYkJrHBhys46HoMl8DLMJHoMPhhRQzcYH7Ci85d6q0CH/xLZGBLZT
         ZFXEMJ+qGYKj/hcrMWftxKDA7wa6ePNfJOFY8rtpl+KuNhLA8PufbJXABsKJuvpOXdrW
         rkM2khnXSclSLGzKTKspPIY9MGDmf4Vo48By4LyAJwDq5dRrW5a0BWThiceY49eJM+mB
         kv3NBjhim5Ii4bi0g7fWiIMkVipG72jRngSg0hxvFiuoZX3qtqj7KA/YWYR9T2NuSEVI
         ARPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Qu0p3hBJIS1tt+CwL8iHr3VvkzVSz5VHHFsNUQJfq4A=;
        b=DrSymas0CwEWWc6ICfy79GYzqlVzdH7hBaZgeAC2yKXhedxB4K+0b+L1eWrrjNpqcs
         pP8IXTK/Yy6i6/7QRnT/ADo227B83Fc5WcJQIdkoTjb/3uSGAu5BpFvl4XNynvx5baV+
         PolapH3eCAj993RS6QCmsUb7cA9kggzUk7vSyCyOgmLpnij0dUaT/AndPrpofJTXT0fX
         hR5C1x3q0XEuVUL/BNDRDWYno0RAfCqL74ZmN9iNtOlfo9Z0Cz8FJlfLDy+dFC2Cw+V/
         xyWfWZWRT8A+4ndBpBTVA4mxTsa5eTKaK4kWyqWjBldFE+Illm3MH6affXk5ZIXeVb0l
         940w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id s16si2595544ejb.349.2019.07.11.02.57.48
        for <linux-mm@kvack.org>;
        Thu, 11 Jul 2019 02:57:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E7565337;
	Thu, 11 Jul 2019 02:57:47 -0700 (PDT)
Received: from [10.162.42.96] (p8cg001049571a15.blr.arm.com [10.162.42.96])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 64DD13F71F;
	Thu, 11 Jul 2019 02:57:36 -0700 (PDT)
Subject: Re: [PATCH] mm/kprobes: Add generic kprobe_fault_handler() fallback
 definition
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>,
 Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
 Ralf Baechle <ralf@linux-mips.org>, Paul Burton <paul.burton@mips.com>,
 James Hogan <jhogan@kernel.org>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Heiko Carstens <heiko.carstens@de.ibm.com>, Vasily Gorbik
 <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S. Miller" <davem@davemloft.net>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
 "Naveen N. Rao" <naveen.n.rao@linux.ibm.com>,
 Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>,
 Masami Hiramatsu <mhiramat@kernel.org>, Allison Randal
 <allison@lohutok.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Enrico Weigelt <info@metux.net>, Richard Fontana <rfontana@redhat.com>,
 Kate Stewart <kstewart@linuxfoundation.org>,
 Mark Rutland <mark.rutland@arm.com>,
 Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck
 <linux@roeck-us.net>, x86@kernel.org, linux-snps-arc@lists.infradead.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org
References: <1562304629-29376-1-git-send-email-anshuman.khandual@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <542893ae-ed64-55b2-11ee-1f19710a25e4@arm.com>
Date: Thu, 11 Jul 2019 15:28:07 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <1562304629-29376-1-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/05/2019 11:00 AM, Anshuman Khandual wrote:
> Architectures like parisc enable CONFIG_KROBES without having a definition
> for kprobe_fault_handler() which results in a build failure. Arch needs to
> provide kprobe_fault_handler() as it is platform specific and cannot have
> a generic working alternative. But in the event when platform lacks such a
> definition there needs to be a fallback.
> 
> This adds a stub kprobe_fault_handler() definition which not only prevents
> a build failure but also makes sure that kprobe_page_fault() if called will
> always return negative in absence of a sane platform specific alternative.
> 
> While here wrap kprobe_page_fault() in CONFIG_KPROBES. This enables stud
> definitions for generic kporbe_fault_handler() and kprobes_built_in() can
> just be dropped. Only on x86 it needs to be added back locally as it gets
> used in a !CONFIG_KPROBES function do_general_protection().
> 
> Cc: Vineet Gupta <vgupta@synopsys.com>
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will@kernel.org>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: Paul Burton <paul.burton@mips.com>
> Cc: James Hogan <jhogan@kernel.org>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Vasily Gorbik <gor@linux.ibm.com>
> Cc: Christian Borntraeger <borntraeger@de.ibm.com>
> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
> Cc: Rich Felker <dalias@libc.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: "Naveen N. Rao" <naveen.n.rao@linux.ibm.com>
> Cc: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
> Cc: Masami Hiramatsu <mhiramat@kernel.org>
> Cc: Allison Randal <allison@lohutok.net>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Enrico Weigelt <info@metux.net>
> Cc: Richard Fontana <rfontana@redhat.com>
> Cc: Kate Stewart <kstewart@linuxfoundation.org>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Guenter Roeck <linux@roeck-us.net>
> Cc: x86@kernel.org
> Cc: linux-snps-arc@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-mips@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-sh@vger.kernel.org
> Cc: sparclinux@vger.kernel.org
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---

Any updates or suggestions on this patch ? Currently there is a build failure on
parisc architecture due to the lack of a kprobe_fault_handler() definition when
CONFIG_KPROBES is enabled and this build failure needs to be fixed.

This patch solves the build problem. But otherwise I am also happy to just define
a stub definition for kprobe_fault_handler() on parisc arch when CONFIG_KPROBES
is enabled, which will avoid the build failure. Please suggest.

