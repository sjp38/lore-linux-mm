Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1016C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 15:36:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF706208E3
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 15:36:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF706208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F77A6B0269; Tue, 11 Jun 2019 11:36:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A7356B026C; Tue, 11 Jun 2019 11:36:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16FBA6B026D; Tue, 11 Jun 2019 11:36:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CEFA46B0269
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 11:36:56 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d13so21260429edo.5
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 08:36:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dwa/kDRxm9yYG399dGithN+pZZhBIwPlTDjvi1Cv4NQ=;
        b=m4bLs0+j/ZnQ5dnDCkMhWGENytldQCkirN6TTrpMElF5CfXN979iBWE3d95u7C7HLQ
         WtEMNlNYsrskKfbfPamiDng67pcKc/Gx9i6u5qI+hDHYnp4LyJ5d8N54Med0MyNeZ+dy
         vVZJkOF7PRC+emwVTRVP9mEeh9b/IuFALAW8+UaGGLZ1H+TTemGsV80/fE7W6jrMDwK2
         Ey44Z5D6xV1ofF8/k45O5yYjvlj3g6VsSKZuVhJUqax/f52tNglZiSSjjybnHU6Es/El
         TLTwXNfDEWrha7jrxhvBT1sqbwnn6Zty4R25qnLHViyMpL0fx+NpcKky4d/lfgNIK3kC
         AJpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAUqX17R1tl4fIKlnex1Olh2gxpq/+giTspWXrXVYoX++ZEI8jRx
	p7epOa2NVBg++HvF7/vhbdh6ytgNwc+AGLt5LMfVqj2cHzg5N2ZaZDb7Rod+oKcMgAEtKJ5quuY
	tWPRpC1EMN3l9jhslBqVQr7nha10xsYPfdYFFTwZh3P/l88nTlnvC2+fDB0LLQK+DLg==
X-Received: by 2002:a17:906:6dc3:: with SMTP id j3mr17057683ejt.258.1560267416260;
        Tue, 11 Jun 2019 08:36:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzlle2k1PuMx3hWDMUpvnyZ9OJ24CMIzQhzqvCJaPrYHxpvaqHUSsbE+HhhLngfw58eyCB
X-Received: by 2002:a17:906:6dc3:: with SMTP id j3mr17057610ejt.258.1560267415456;
        Tue, 11 Jun 2019 08:36:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560267415; cv=none;
        d=google.com; s=arc-20160816;
        b=GsnR/kLvOKWV5qYy2CV/At/1n9tjZxMhGSrDQzlZoz44jtcbIMRaQzcqw9Zz6vy7wf
         1GVElAsJTgpsig9NenrBf7OI53/K7eNsE7jMS66HBZYgp1e1JQkyW0aSri0hJ61Hg2Ng
         1rL1re+DgXwOVihmoSqT8u4y8QGhi7zDnhBKVQzJubM6tBMguwdc2SpyPv07R9FNiH4t
         PcPNn2FexsxMm7ZXSPbUR8p7+D5ngJe3xYiNpPG+pkMU67/mf0daJg7d+wWdXuzm4YgA
         HEGwKc+q3k0oSHhhOdpZz/Vk07KTsvt2D/ECl55o3vk/xP4avYfxeXcyl0UyynyIGgwO
         HrEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dwa/kDRxm9yYG399dGithN+pZZhBIwPlTDjvi1Cv4NQ=;
        b=ldYs6W0VmCQN39TvkFBFrNsVh74oTYf6Fk6PdPOIvwRh3v8y8wpd0L5fs2konGQs6E
         sdvp8JG0v6SAr0tyM6eB4pwGDtK+kgkNdnF35uDJTP+6eq3E4xsCxJF33IRg57XUKww+
         BDUYkXfHbxHDQ+ioNHPnDBtnh7AypOhGYldMfVMxtao9waX9XFL1PJm8W0x+it0EJtqd
         exXpS4Gx1ivGipiLl0g0WSu9enEqB7rgiYYovrGkNHqifghanFJ2pmu2/iI6r2p5EnbB
         lEX8wbF/FhDbgk8E1LM3gd9jjZ8AjLnplDzom2O5tnASJg9JFf369z0H+LhjjpZl3tR7
         FT+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id m18si3236466ejq.1.2019.06.11.08.36.55
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 08:36:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9101E337;
	Tue, 11 Jun 2019 08:36:54 -0700 (PDT)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1F2713F246;
	Tue, 11 Jun 2019 08:36:52 -0700 (PDT)
Date: Tue, 11 Jun 2019 16:36:50 +0100
From: Will Deacon <will.deacon@arm.com>
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 02/20] arm64: mm: Add p?d_large() definitions
Message-ID: <20190611153650.GB4324@fuggles.cambridge.arm.com>
References: <20190403141627.11664-1-steven.price@arm.com>
 <20190403141627.11664-3-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403141627.11664-3-steven.price@arm.com>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 03:16:09PM +0100, Steven Price wrote:
> walk_page_range() is going to be allowed to walk page tables other than
> those of user space. For this it needs to know when it has reached a
> 'leaf' entry in the page tables. This information will be provided by the
> p?d_large() functions/macros.

I've have thought p?d_leaf() might match better with your description above,
but I'm not going to quibble on naming.

For this patch:

Acked-by: Will Deacon <will.deacon@arm.com>

Will

