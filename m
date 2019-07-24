Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0770C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:07:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61F1C21BF6
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:07:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61F1C21BF6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB4276B000A; Wed, 24 Jul 2019 10:07:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C64DE8E0003; Wed, 24 Jul 2019 10:07:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2DD58E0002; Wed, 24 Jul 2019 10:07:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 645C66B000A
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:07:43 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id b135so9838281wmg.1
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:07:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rmLwFMJxpLXrW8HVnU73lNn8PQbvGedBSVolGY1DK1c=;
        b=rUgztbMCCodu+01Tvk72tmKuucPxxOLxJ9srUztwvGWlR488T+rk4hj/ixKSOXZoDE
         lr/E5dT0fwsWx37PlivrugRVFXFwGyAVDxG1GARJRKiZYI9Fo1fMXPwfyoFvBQ5AHdh8
         JH0iRfFl55OABk5Eee4rEbYD1/5aDPmsdoE/vkdC1uuYRzCx1MRkxF0pL1dGIi/s73gR
         hL7HzMqhwU3LLK2yGOsvYb07hQ2zgVpRVmu78K+lxTbQK3aSf2XMhVrEfMqfH+ZVydh1
         lQyz6UMGrHGTjnnT+qYwf24gVg9ZF6I/YWBtpCpfOQiBlHGfk0421xt5aw2YU36mMz+z
         f1Xg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAXT/2/jXJyI48c6C3tIewSwWI3hMfv8hTrA+vSEqwrTgXKmQR50
	xRicbylNVhLz9mxO1NkBpnbqdVfOCoaU/BPcoZLDoQJw0cEOroBtoU9N4NVJZdeCWxm15SIfVnw
	GzzeJJFpYL/Ke/ZdAIDbX7E09rZBZTJc5xKgyG2nCUbzHYkCskbxECnLyIWnTjXX+mQ==
X-Received: by 2002:adf:f646:: with SMTP id x6mr93671720wrp.18.1563977263003;
        Wed, 24 Jul 2019 07:07:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLeKRU8wc/Y6R73B9iokbayt5yxr6rI+H7D9RxBa39epEzwtdb3y5d94jqg1NsjWE7mYIb
X-Received: by 2002:adf:f646:: with SMTP id x6mr93671643wrp.18.1563977262300;
        Wed, 24 Jul 2019 07:07:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563977262; cv=none;
        d=google.com; s=arc-20160816;
        b=RH9p6fodcqkwmDsrBjMmR7IP0MoETSJya5lViD9qpaS7EMPB7rTglojf4fmSJnUHbv
         AwKgAE4Eu3yP0hHSDyeGPYLhpKcF2ToJ5OzJZTcz/KJwazToSS7tRggpqnoGgcWBa6uz
         x2heYUE0V//ncLyleIgvLlWKMEadNy65kD8NMTdiiCMA8AMQSaGqm/bZDzS6XV7NVuSz
         GNlnLL/rtyITxAP2NiAKQvBNKV8gPF0bVj21iaZq6NKY07oQOZwGP1sxwp9rNwf9mm/5
         ZS7fDtmKU8s4Tgf8lF4gh474XImwRoDwYZxZ0gabJxt1ZAJcc7NWj/SYU0EeGc5vv8K5
         kUow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rmLwFMJxpLXrW8HVnU73lNn8PQbvGedBSVolGY1DK1c=;
        b=jrBVZlQoryKQ7pqxHhwrrNySLjrPEBKaatB97GZ35D9NAVgGN+HA/LQVAzOlhBWYiG
         mTu0OH/smCmItRVfAbRCENuC/BQq2QL+L7VlH6w5+6qZfgjolRU2/3bRayIqi/We0UID
         x3ADZSBVV+nRyKBeKUkgqGiBNvKANnKBHF12JWoHIgsrSWpLuM308huLKT5kTmfmLu92
         yn+Mj36sGgPAexk1gyzgeT3dsMBacOZsG31UABCLbS25yju5xoNAV+3+EjtAmrrSrwR9
         VyECp0F/ITFeDAmGWGjvYnmlAO3PxC8cOYqtzlxU3uDkgs7q3yVSxpNqgb+6VWcsFtzW
         bxxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id b57si9186949edc.406.2019.07.24.07.07.40
        for <linux-mm@kvack.org>;
        Wed, 24 Jul 2019 07:07:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 449AE28;
	Wed, 24 Jul 2019 07:07:40 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C7DA53F71A;
	Wed, 24 Jul 2019 07:07:37 -0700 (PDT)
Date: Wed, 24 Jul 2019 15:07:35 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Steven Price <steven.price@arm.com>, x86@kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	James Morse <james.morse@arm.com>, Will Deacon <will@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-arm-kernel@lists.infradead.org,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v9 00/21] Generic page walk and ptdump
Message-ID: <20190724140735.GD2624@lakrids.cambridge.arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190723101639.GD8085@lakrids.cambridge.arm.com>
 <e108b8a6-deca-e69c-b338-52a98b14be86@arm.com>
 <alpine.DEB.2.21.1907241541570.1791@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1907241541570.1791@nanos.tec.linutronix.de>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 03:57:33PM +0200, Thomas Gleixner wrote:
> On Wed, 24 Jul 2019, Steven Price wrote:
> > On 23/07/2019 11:16, Mark Rutland wrote:
> > > Are there any visible changes to the arm64 output?
> > 
> > arm64 output shouldn't change. I've confirmed that "efi_page_tables" is
> > identical on a Juno before/after the change. "kernel_page_tables"
> > obviously will vary depending on the exact layout of memory, but the
> > format isn't changed.
> > 
> > x86 output does change due to patch 14. In this case the change is
> > removing the lines from the output of the form...
> > 
> > > 0xffffffff84800000-0xffffffffa0000000         440M                               pmd
> > 
> > ...which are unpopulated areas of the memory map. Populated lines which
> > have attributes are unchanged.
> 
> Having the hole size and the level in the dump is a very conveniant thing.

Mhmm; I thought that we logged which level was empty on arm64 (but
apparently not), since knowing the structure can be important.

> Right now we have:
> 
> 0xffffffffc0427000-0xffffffffc042b000          16K     ro                     NX pte
> 0xffffffffc042b000-0xffffffffc042e000          12K     RW                     NX pte
> 0xffffffffc042e000-0xffffffffc042f000           4K                               pte
> 0xffffffffc042f000-0xffffffffc0430000           4K     ro                     x  pte
> 0xffffffffc0430000-0xffffffffc0431000           4K     ro                     NX pte
> 0xffffffffc0431000-0xffffffffc0433000           8K     RW                     NX pte
> 0xffffffffc0433000-0xffffffffc0434000           4K                               pte
> 0xffffffffc0434000-0xffffffffc0436000           8K     ro                     x  pte
> 0xffffffffc0436000-0xffffffffc0438000           8K     ro                     NX pte
> 0xffffffffc0438000-0xffffffffc043a000           8K     RW                     NX pte
> 0xffffffffc043a000-0xffffffffc043f000          20K                               pte
> 0xffffffffc043f000-0xffffffffc0444000          20K     ro                     x  pte
> 0xffffffffc0444000-0xffffffffc0447000          12K     ro                     NX pte
> 0xffffffffc0447000-0xffffffffc0449000           8K     RW                     NX pte
> 0xffffffffc0449000-0xffffffffc044f000          24K                               pte
> 0xffffffffc044f000-0xffffffffc0450000           4K     ro                     x  pte
> 0xffffffffc0450000-0xffffffffc0451000           4K     ro                     NX pte
> 0xffffffffc0451000-0xffffffffc0453000           8K     RW                     NX pte
> 0xffffffffc0453000-0xffffffffc0458000          20K                               pte
> 0xffffffffc0458000-0xffffffffc0459000           4K     ro                     x  pte
> 0xffffffffc0459000-0xffffffffc045b000           8K     ro                     NX pte
> 
> with your change this becomes:
> 
> 0xffffffffc0427000-0xffffffffc042b000          16K     ro                     NX pte
> 0xffffffffc042b000-0xffffffffc042e000          12K     RW                     NX pte
> 0xffffffffc042f000-0xffffffffc0430000           4K     ro                     x  pte
> 0xffffffffc0430000-0xffffffffc0431000           4K     ro                     NX pte
> 0xffffffffc0431000-0xffffffffc0433000           8K     RW                     NX pte
> 0xffffffffc0434000-0xffffffffc0436000           8K     ro                     x  pte
> 0xffffffffc0436000-0xffffffffc0438000           8K     ro                     NX pte
> 0xffffffffc0438000-0xffffffffc043a000           8K     RW                     NX pte
> 0xffffffffc043f000-0xffffffffc0444000          20K     ro                     x  pte
> 0xffffffffc0444000-0xffffffffc0447000          12K     ro                     NX pte
> 0xffffffffc0447000-0xffffffffc0449000           8K     RW                     NX pte
> 0xffffffffc044f000-0xffffffffc0450000           4K     ro                     x  pte
> 0xffffffffc0450000-0xffffffffc0451000           4K     ro                     NX pte
> 0xffffffffc0451000-0xffffffffc0453000           8K     RW                     NX pte
> 0xffffffffc0458000-0xffffffffc0459000           4K     ro                     x  pte
> 0xffffffffc0459000-0xffffffffc045b000           8K     ro                     NX pte
> 
> which is 5 lines less, but a pain to figure out the size of the holes. And
> it becomes even more painful when the holes go across different mapping
> levels.

I agree.

Steven, could you align arm64 with the x86 behaviour here?

Thanks,
Mark.

