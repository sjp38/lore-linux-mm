Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D0DFC04AB1
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 02:02:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F89E21473
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 02:02:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="15Oxqiet"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F89E21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD8E86B0003; Mon, 13 May 2019 22:02:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8AD66B0005; Mon, 13 May 2019 22:02:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B79066B0007; Mon, 13 May 2019 22:02:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 811976B0003
	for <linux-mm@kvack.org>; Mon, 13 May 2019 22:02:45 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j1so10885784pff.1
        for <linux-mm@kvack.org>; Mon, 13 May 2019 19:02:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/TgRi4Ld1Qw9+mN6KywYX/xBglWftuhDT8EpdWRjHUk=;
        b=Chf/nqiieOJbJj6B2JE2gaSVXGaRksSck6TL39xTT39AAY9mtjPXMGGqzA39zvNVwu
         K+IVfR7Rcj/dUvRul+JfQKKYSyYw8jYizqmY+t4kaz6e6h7UkcsQylc3eKqC+MaCrP0+
         lXP+AIYOLLYLPRp3WvNe3T3oC4lmMAvPpByep8b10npHm77qrHzn7WmKsRWeeDuvxop2
         pZjuRRrRJEmpVzmdA5ZPBvbpfIX4HhBLuajxgotifbNtZveRdC6wlcMYjLzZl+s7lGC0
         sltgBUSbTIsHnVoj7KEg65SNzPHDgdGdXiHwGFHf10MpAZKTJ4HbOf4ELI0gaq2LYgwH
         mSiw==
X-Gm-Message-State: APjAAAVmoXQjqLPC8pjjjhrFD5c/AcUTT7l8P5/B1G4LsbjZ+xFifZ+R
	tQWz3IrywUjG9AJAAyJm7G1m/Ja2ZKg3d4KQ/wHmS4UpGX6dNMUr1cYEYItQbe1wQQBHQHmV0Lz
	qgnNGREnlCFQv4nLgi1miliabYQy671K3UbUufsoCN0+8qNqyXwHy1+TRU5tQR36u6Q==
X-Received: by 2002:aa7:83d4:: with SMTP id j20mr16416970pfn.90.1557799364873;
        Mon, 13 May 2019 19:02:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwqQUBKJzeGbIINBs/oppEMxRp/gA5X4Ez8n7s9jObwxBB9Tu0zDYTEItAcq4U4VfsTB/6
X-Received: by 2002:aa7:83d4:: with SMTP id j20mr16416898pfn.90.1557799363983;
        Mon, 13 May 2019 19:02:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557799363; cv=none;
        d=google.com; s=arc-20160816;
        b=Hb/A/0od+B5y+7CYsUukYNbRRRAJ86WrdSDynDGNMpHS8fE4cjA/jnFoEfKX2+Hvq+
         ycuUs45MLgHlxqG7HL1xtlXlLoq0lPwji/4InHemFAV4oRgT5hWMCCGvBls2Rzm9te/C
         RdFWYJulEFbinGyz50xgPo6/6czEDpm6tmeB19bW+l+Iq4OMyeQfW79VqRvtiC6X0h6z
         uYSOt5RC30PJQaRKTdw4LkhUo2kL+hEX6V0/ovwSeAA/fR2zvIOjPB5r04eRc6WQ+gu5
         PdfTDhRpfwPLMIwbxyrZeJm/PgB98gwuqxbctCL0zWp8rmD0dV+VN3N/gfYHyewUK6ut
         MXYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/TgRi4Ld1Qw9+mN6KywYX/xBglWftuhDT8EpdWRjHUk=;
        b=IV43U0H/Pg38vvVcKwhKyCYSTvLp0QwXecQfKsqsE6TmF0teWfmx4+rT5JUP+9LThf
         O7Q2C6t3RaSg6Ey371I+/KyIMOHMaiun8Q9CW3/3cHq5gr07eri2jDRFexVUbvRzsTv3
         DBPe19WvVuP/ZjIiNhBzJD4uRR9znBCW2aMOspcQJHOVe52HCIXq4ybRbqGuFT4WWeMi
         l3GXkepunIiIQXaoHVCeS3qA7L7G9D/g7RswNhKS/VVcpMP5+lur95jOpKnpPolpH+gv
         EsTwfYQXQRCTDS010osYG0I02b8Io4GDEXt1PToUdXhBf2O8g50e/FBgY/1SbYr3l6VS
         hZ8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=15Oxqiet;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z33si17953185pgl.537.2019.05.13.19.02.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 19:02:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=15Oxqiet;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com [209.85.128.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 535132168B
	for <linux-mm@kvack.org>; Tue, 14 May 2019 02:02:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557799363;
	bh=4OBmtfQllm0RymwAbmCzcP2d3KH9f8oCMkSmd1HlaAA=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=15OxqietpeRfGcIVu5u4YGK6lQMkA8PXcTMZtnOt1lzuJODROCsf/5K71H11TL4ul
	 XIQLz6xsf1OfhAS72AXJbUsNOQo5rEO7Y4JJrc/YQcRpjxUqD+Y1DbYwehJXNSN6/d
	 Q0NETdnisf6YcHjz5rFLGoBCziHZbk+A/5MudBlA=
Received: by mail-wm1-f51.google.com with SMTP id f204so1124008wme.0
        for <linux-mm@kvack.org>; Mon, 13 May 2019 19:02:43 -0700 (PDT)
X-Received: by 2002:a1c:486:: with SMTP id 128mr16481232wme.83.1557799361797;
 Mon, 13 May 2019 19:02:41 -0700 (PDT)
MIME-Version: 1.0
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-25-git-send-email-alexandre.chartre@oracle.com>
 <20190513151500.GY2589@hirez.programming.kicks-ass.net> <13F2FA4F-116F-40C6-9472-A1DE689FE061@oracle.com>
In-Reply-To: <13F2FA4F-116F-40C6-9472-A1DE689FE061@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 13 May 2019 19:02:30 -0700
X-Gmail-Original-Message-ID: <CALCETrUcR=3nfOtFW2qt3zaa7CnNJWJLqRY8AS9FTJVHErjhfg@mail.gmail.com>
Message-ID: <CALCETrUcR=3nfOtFW2qt3zaa7CnNJWJLqRY8AS9FTJVHErjhfg@mail.gmail.com>
Subject: Re: [RFC KVM 24/27] kvm/isolation: KVM page fault handler
To: Liran Alon <liran.alon@oracle.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Alexandre Chartre <alexandre.chartre@oracle.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Andrew Lutomirski <luto@kernel.org>, kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, jan.setjeeilers@oracle.com, 
	Jonathan Adams <jwadams@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 2:26 PM Liran Alon <liran.alon@oracle.com> wrote:
>
>
>
> > On 13 May 2019, at 18:15, Peter Zijlstra <peterz@infradead.org> wrote:
> >
> > On Mon, May 13, 2019 at 04:38:32PM +0200, Alexandre Chartre wrote:
> >> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> >> index 46df4c6..317e105 100644
> >> --- a/arch/x86/mm/fault.c
> >> +++ b/arch/x86/mm/fault.c
> >> @@ -33,6 +33,10 @@
> >> #define CREATE_TRACE_POINTS
> >> #include <asm/trace/exceptions.h>
> >>
> >> +bool (*kvm_page_fault_handler)(struct pt_regs *regs, unsigned long error_code,
> >> +                           unsigned long address);
> >> +EXPORT_SYMBOL(kvm_page_fault_handler);
> >
> > NAK NAK NAK NAK
> >
> > This is one of the biggest anti-patterns around.
>
> I agree.
> I think that mm should expose a mm_set_kvm_page_fault_handler() or something (give it a better name).
> Similar to how arch/x86/kernel/irq.c have kvm_set_posted_intr_wakeup_handler().
>
> -Liran
>

This sounds like a great use case for static_call().  PeterZ, do you
suppose we could wire up static_call() with the module infrastructure
to make it easy to do "static_call to such-and-such GPL module symbol
if that symbol is in a loaded module, else nop"?

