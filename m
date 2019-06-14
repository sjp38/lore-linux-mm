Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A882DC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 05:15:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BD5C20850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 05:15:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BD5C20850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D34B8E0004; Fri, 14 Jun 2019 01:15:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 084ED8E0002; Fri, 14 Jun 2019 01:15:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8D608E0004; Fri, 14 Jun 2019 01:15:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 98A768E0002
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 01:15:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s7so2050440edb.19
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 22:15:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=cOyMxqTgBIbrD61iKN0GlHtb83ZM3YbYYmlYOy36+O4=;
        b=jTT8DM1S6bIqpa04vz405isuaQnZ9tkA+HVer0AqrjeoRyIgRUcK4TAhh6W82p/uGJ
         Q9cnoC4mkgirZ+ne0QXYcr6eQMimYYnEiX+WJAolOq2tIueGrnlQEMBHIYEB5uj1MKoB
         WSjy7JR0IxmbNghaIK1Yzs1/uVgh6qk9DlnGBzm5uvc+eDhttwuyTayll3fdA9gf65nZ
         o7G/N1TC9bPqiLl4s1T+3udwoiY9+zoUpBDyytMA6Pdk7lzSvfd7tA8J6+SYJntr1+qn
         EgAU2UeIYN43nIFf7M+ANGP3v2Plx/P+aSKRyEWf70cRSQihT38MDSL8hxMXcNpUARbt
         AtAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVZen8rmR0d99xoUr2A0yG0a3DJs+CB6hMDtH3Mf1RLe5vIwiEK
	fgtrBiaFL07DyX0fflf7Hbos/NM3+vDK99+Geqkb7N9ymGddVPpow3kMPg8BK3oYzyHoLmwXstx
	2SOR4TPhkfXmxDpGId0fofQiypAHMt2yhnCevWe6k0AV9zCcxb0a+U3KmbLjbKwCbuw==
X-Received: by 2002:a50:d2d3:: with SMTP id q19mr21841561edg.64.1560489339126;
        Thu, 13 Jun 2019 22:15:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2I2zI32y4roPlDK0QPFxU/2k/31gDcbmIyhG0bmNgN7OuN6E8M88r1ihPRwK0uyDnOZpk
X-Received: by 2002:a50:d2d3:: with SMTP id q19mr21841517edg.64.1560489338447;
        Thu, 13 Jun 2019 22:15:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560489338; cv=none;
        d=google.com; s=arc-20160816;
        b=eOYd0jDCiDOB4G5UQ+qeauZepT9KSX6kXFJZKNl5/2giOVBZMcjT5V5hWsjTC//sRf
         RXdadsk15tSv++CG0eJ4auNDwsWqavdKN8NmNt7lXbF1WD7H48/XhTvF13zdsEA4O8kv
         21myRV4Djf7KH7hNsb7u3784hM9Y77GbqAzK1Hw6hoQ9n5zZMP2iR5UQM0OhO95PfZVb
         J0b9nUsHd7S3oK9ytEYR9Ri6jDIPantrEOCqqfjLyFI4ZVYKIbwKApzUCUIejWLACD2x
         xlS5BdHZnRAHSaPxX2lIDGnioD8IKFGH162ioAsqoXbv4hUYfYhLZ/0vM7fvCPRS/zhP
         TOZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=cOyMxqTgBIbrD61iKN0GlHtb83ZM3YbYYmlYOy36+O4=;
        b=UDnjS6VZId3b5Da5668VdcQx4TCZEWqUyf8TFVOFlM2fFleCvBkm3vmcYK6SWDxyq9
         FpmbHzUSnYHrdq9QrGb81nbHJdwFi1d87pZbB5dlde01sMZV/clYdmuZcKX0aFNbVhzd
         bWtBqwXdNP4ixl2Gf0WT+lNM7XP2RLyE7SVnSUiaVGNX5Ia9fgSj8tge+9QE8F+wnFEl
         Rsl9sltDh2hjcNlAmrDSSyCePM5khf4P0qmS/U/L5Dm67AyapCDHW3I310MceMyjY4VQ
         LcwXxgplLL9RCqIYNrliRLe/70NsoY2ATkQ7MGUdmJuVui7Od3aZq+/ga+xnYwiMCphy
         spbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g56si1291195edb.70.2019.06.13.22.15.38
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 22:15:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 29721367;
	Thu, 13 Jun 2019 22:15:37 -0700 (PDT)
Received: from [10.162.41.168] (p8cg001049571a15.blr.arm.com [10.162.41.168])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B446E3F246;
	Thu, 13 Jun 2019 22:15:25 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-snps-arc@lists.infradead.org, linux-mips@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>,
 Mark Rutland <mark.rutland@arm.com>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 Andrey Konovalov <andreyknvl@google.com>,
 Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>,
 Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>,
 Fenghua Yu <fenghua.yu@intel.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>,
 "David S. Miller" <davem@davemloft.net>, Thomas Gleixner
 <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>,
 Dave Hansen <dave.hansen@linux.intel.com>, Vineet Gupta
 <vgupta@synopsys.com>, James Hogan <jhogan@kernel.org>,
 Paul Burton <paul.burton@mips.com>, Ralf Baechle <ralf@linux-mips.org>
References: <1560420444-25737-1-git-send-email-anshuman.khandual@arm.com>
 <20190613130408.3091869d8e50d0524157523f@linux-foundation.org>
Message-ID: <c3316aca-2005-e092-80f6-ebd7652bd04f@arm.com>
Date: Fri, 14 Jun 2019 10:45:44 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190613130408.3091869d8e50d0524157523f@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 06/14/2019 01:34 AM, Andrew Morton wrote:
> On Thu, 13 Jun 2019 15:37:24 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:
> 
>> Architectures which support kprobes have very similar boilerplate around
>> calling kprobe_fault_handler(). Use a helper function in kprobes.h to unify
>> them, based on the x86 code.
>>
>> This changes the behaviour for other architectures when preemption is
>> enabled. Previously, they would have disabled preemption while calling the
>> kprobe handler. However, preemption would be disabled if this fault was
>> due to a kprobe, so we know the fault was not due to a kprobe handler and
>> can simply return failure.
>>
>> This behaviour was introduced in the commit a980c0ef9f6d ("x86/kprobes:
>> Refactor kprobes_fault() like kprobe_exceptions_notify()")
>>
>> ...
>>
>> --- a/arch/arm/mm/fault.c
>> +++ b/arch/arm/mm/fault.c
>> @@ -30,28 +30,6 @@
>>  
>>  #ifdef CONFIG_MMU
>>  
>> -#ifdef CONFIG_KPROBES
>> -static inline int notify_page_fault(struct pt_regs *regs, unsigned int fsr)
> 
> Some architectures make this `static inline'.  Others make it
> `nokprobes_inline', others make it `static inline __kprobes'.  The
> latter seems weird - why try to put an inline function into
> .kprobes.text?
> 
> So..  what's the best thing to do here?  You chose `static
> nokprobe_inline' - is that the best approach, if so why?  Does
> kprobe_page_fault() actually need to be inlined?

Matthew had suggested that (nokprobe_-inline) based on current x86
implementation. But every architecture already had an inlined definition
which I did not want to deviate from.

> 
> Also, some architectures had notify_page_fault returning int, others
> bool.  You chose bool and that seems appropriate and all callers are OK
> with that.

I would believe so. No one has complained yet :)

