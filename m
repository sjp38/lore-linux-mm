Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 504DCC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:20:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 087A02183F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:20:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 087A02183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FE7B6B0006; Wed, 17 Apr 2019 17:20:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AF0D6B0007; Wed, 17 Apr 2019 17:20:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 89E9D6B0008; Wed, 17 Apr 2019 17:20:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3C53E6B0006
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 17:20:14 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id t10so76548wrp.3
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:20:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=QXC34O10+SYM03YZaJNXk8fM16dOe9sLFuJmsxUwR3M=;
        b=maG8qhBU6PB0QxnPjdOSgfh4taLRM8U6g1RyymFMfSvFqOohQiyRtSJHBaPnh1/Zk6
         88M5BOD7+d3H8Ok+jYAx+Wm/dfI2HQle0h21SUBWXz6vbEcZHMmDljRJp/UZ/zme6l2W
         V2oSiJxgYCHIcZGqm25mmDIwxrHMGlknsU7HDIEdI/lNRP9hMfLPDdmir1cb3ztGwz7Z
         Qf2xOZDuB9kO/h+7yoiuCQaeZW1xbteJdDV3uZ6D0Jz8KI/X2qmcr29T7DqfYqTouTKz
         g4JNtUOkfNF98MCbWZDTa3pYyHo6NjnAox3TLJxWA4xRQWGVPNhCGlUxKOF+5awknuYh
         QZuA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVMEJy76PoX/T72q0dOrlRlbAacdAeatysIB6dGfvPDiqq7sEFl
	y/AXCKj88WbOD4h5loiztYUEFoNIsxu7gHo85IODUk6EH9SVxr6LWUvhp6fjWlCT8nFH3+h0Vjp
	z9a6ULzPcpOjff3M7aDOK8y/xfkQXkQYeaU5HIgTh84ewiufX9VaQ3OnGJaRNPbA9jw==
X-Received: by 2002:adf:e487:: with SMTP id i7mr29665054wrm.264.1555536013724;
        Wed, 17 Apr 2019 14:20:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNnw/L5J7mePKn60Q6ZEjJnPQiSthD66H8I9v14byfYEXk5SF5bGihvW2rbZEtLETs95wj
X-Received: by 2002:adf:e487:: with SMTP id i7mr29665016wrm.264.1555536012954;
        Wed, 17 Apr 2019 14:20:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555536012; cv=none;
        d=google.com; s=arc-20160816;
        b=GBAHQ46vdjZhzmMisMn7z2xmM2TU2x1LAPVXyDvdUpDhezr/LxQMj67Fv1N6fUh1dw
         12sOzwSPKMd4pDkL+bF0UkMW5QIpe/Hekp8CATFC/2ihbkGjP3W1omqIHXyfHqeFsnKt
         2uK3oiJMIuwGk9ANoFoQVxZoVMz64qe4K/9Bgy9PSxgGwsN5RRXiHC0mO9j1RkoD4Vzk
         etIWDOAxz/eFrsYoWKOYRWHWjqoF28XkOiqn0QMTz7Vl3GeU/wcJ80PNJeZ3BWyUUfL+
         nGYGdfbyWFY0L0AHHV5cv6D8WJ7HHoZGVsCdP1RF5sFuduTPHhLpuJK7+CAscJBvwUbJ
         lcjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=QXC34O10+SYM03YZaJNXk8fM16dOe9sLFuJmsxUwR3M=;
        b=LokPxKoup9Ogohwc31jXNuWzZnBXhJJGz23R+6GN8vqzTXW+izajfzWlFZqW8nJTu/
         mQSKkGs4mPGrJNL9Oocv3JOxbXerbBkpEXuEwzRbPI5RyXmSHq6q2bB9cq/SJVixnMN6
         q6VBD7Mu8l/idg2bM1lcccLeSg+V0hHrVeeFPJvWmznF/wiA4SAYESx95RsLTXju+dVZ
         sxhM3HL6Xa2zN3d1Df5GtbmgeGJh/0xXlXKdB86KZeLnEquZeI8CIgSGrWyEx0pYXoR8
         l2UfckWERsd8tUtJK9poVlG8uWqroCmqmIGgcnOGWWy2fhUtS8U1G6dJvp3iH44kiYIT
         cAAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id a127si68203wmh.202.2019.04.17.14.20.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 17 Apr 2019 14:20:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hGryH-0005mC-Kp; Wed, 17 Apr 2019 23:19:57 +0200
Date: Wed, 17 Apr 2019 23:19:50 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Nadav Amit <nadav.amit@gmail.com>
cc: Ingo Molnar <mingo@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, 
    juergh@gmail.com, Tycho Andersen <tycho@tycho.ws>, jsteckli@amazon.de, 
    keescook@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, 
    Juerg Haefliger <juerg.haefliger@canonical.com>, 
    deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, 
    David Woodhouse <dwmw@amazon.co.uk>, 
    Andrew Cooper <andrew.cooper3@citrix.com>, jcm@redhat.com, 
    Boris Ostrovsky <boris.ostrovsky@oracle.com>, 
    iommu <iommu@lists.linux-foundation.org>, X86 ML <x86@kernel.org>, 
    linux-arm-kernel@lists.infradead.org, 
    "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
    Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, 
    Linux-MM <linux-mm@kvack.org>, 
    LSM List <linux-security-module@vger.kernel.org>, 
    Khalid Aziz <khalid@gonehiking.org>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, 
    Dave Hansen <dave@sr71.net>, Borislav Petkov <bp@alien8.de>, 
    "H. Peter Anvin" <hpa@zytor.com>, Arjan van de Ven <arjan@infradead.org>, 
    Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
In-Reply-To: <063753CC-5D83-4789-B594-019048DE22D9@gmail.com>
Message-ID: <alpine.DEB.2.21.1904172317460.3174@nanos.tec.linutronix.de>
References: <cover.1554248001.git.khalid.aziz@oracle.com> <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com> <20190417161042.GA43453@gmail.com> <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com> <20190417170918.GA68678@gmail.com>
 <56A175F6-E5DA-4BBD-B244-53B786F27B7F@gmail.com> <20190417172632.GA95485@gmail.com> <063753CC-5D83-4789-B594-019048DE22D9@gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="8323329-1402638458-1555535997=:3174"
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1402638458-1555535997=:3174
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Wed, 17 Apr 2019, Nadav Amit wrote:
> > On Apr 17, 2019, at 10:26 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >> As I was curious, I looked at the paper. Here is a quote from it:
> >> 
> >> "In x86-64, however, the permissions of physmap are not in sane state.
> >> Kernels up to v3.8.13 violate the W^X property by mapping the entire region
> >> as “readable, writeable, and executable” (RWX)—only very recent kernels
> >> (≥v3.9) use the more conservative RW mapping.”
> > 
> > But v3.8.13 is a 5+ years old kernel, it doesn't count as a "modern" 
> > kernel in any sense of the word. For any proposed patchset with 
> > significant complexity and non-trivial costs the benchmark version 
> > threshold is the "current upstream kernel".
> > 
> > So does that quote address my followup questions:
> > 
> >> Is this actually true of modern x86-64 kernels? We've locked down W^X
> >> protections in general.
> >> 
> >> I.e. this conclusion:
> >> 
> >>  "Therefore, by simply overwriting kfptr with 0xFFFF87FF9F080000 and
> >>   triggering the kernel to dereference it, an attacker can directly
> >>   execute shell code with kernel privileges."
> >> 
> >> ... appears to be predicated on imperfect W^X protections on the x86-64
> >> kernel.
> >> 
> >> Do such holes exist on the latest x86-64 kernel? If yes, is there a
> >> reason to believe that these W^X holes cannot be fixed, or that any fix
> >> would be more expensive than XPFO?
> > 
> > ?
> > 
> > What you are proposing here is a XPFO patch-set against recent kernels 
> > with significant runtime overhead, so my questions about the W^X holes 
> > are warranted.
> > 
> 
> Just to clarify - I am an innocent bystander and have no part in this work.
> I was just looking (again) at the paper, as I was curious due to the recent
> patches that I sent that improve W^X protection.

It's not necessarily a W+X issue. The user space text is mapped in the
kernel as well and even if it is mapped RX then this can happen. So any
kernel mappings of user space text need to be mapped NX!

Thanks,

	tglx
--8323329-1402638458-1555535997=:3174--

