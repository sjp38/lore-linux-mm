Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C457BC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 19:27:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EA3A21850
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 19:27:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EA3A21850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D6CE8E0003; Wed, 27 Feb 2019 14:27:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AD288E0001; Wed, 27 Feb 2019 14:27:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C4198E0003; Wed, 27 Feb 2019 14:27:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id D9E278E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 14:27:54 -0500 (EST)
Received: by mail-ua1-f70.google.com with SMTP id m12so1661816uao.9
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 11:27:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=3cLq+kIlMMXRZaenVxSwc6pfzBM/ls2MR1D4QP0Hu2k=;
        b=axrXgCbeE1oq0lQwDbF6uLPwO8KB6Ff7xwqGVZeDN+tQxWymCJGWbXzWOG2ppI2jwD
         olFeWIkhv1s2zDiALNpKIV9RylJjZfDuJshijDL4b/9XFukIlBr+Sl0pOcZhoGAEu+LB
         1t16KmhyACkKDpyPsQNeAiHBdya6Pvunoeu2X0WaIa/aJJ9+Nl517iwhsOUl1qoefD0W
         bQ4ikL8C6aIR46sGPwD2OirfwC7lTQULJ82+7BiJBotIwa7oaUWawtyzna2Ph/4kN2dL
         elBNvHZHT2/FmJEhqosNBN2xYr0DYNO3urSxCpYAAdc3gnCeuJ2mu+NOj1aSY0MaS51t
         xzPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Gm-Message-State: AHQUAuZ7Gdz04ydLtsqWOfNZ+mGMLTJ5HtzGSRRLituljIGrA8r9ZYvV
	eMLnHtJQGY6wVysOUvtALhAqNc/Z203a8zny5OktZrisC4r+LmgYcDjDxqcLENv5EadyJoNy8ZD
	xNA+Fh0cR+lwgFJjMDf3HYJHvox53ST9Y7JvL8C3BG9HvYz2jdl4wmoQfZUFt7Rvj0aOYEVftpN
	IWk7xYn44wUOYdiw6ryYgC2a4CXSLGp5KjRBAp6Rwzl+CWQhuOjqWggY2+6UB2YbU1kwhUeJ4MR
	keDZ4y1P1YZelkDQbjqx25a1GQ+5Bst2MzymR/K7zviQMLiu3Nl+cEjG9WSZkcTOp8U+8qagkx2
	UFVOGyft2uX4VzCbQZD54fycr99sK0UyJIipRE/sMg0V9oj5NYtZPynhHfrR1IraADagy1ruMg=
	=
X-Received: by 2002:a67:dc0d:: with SMTP id x13mr1981472vsj.217.1551295674477;
        Wed, 27 Feb 2019 11:27:54 -0800 (PST)
X-Received: by 2002:a67:dc0d:: with SMTP id x13mr1981427vsj.217.1551295673649;
        Wed, 27 Feb 2019 11:27:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551295673; cv=none;
        d=google.com; s=arc-20160816;
        b=kwq0wQrI9a1Hww+3YQ35s77gr8wI13oHLo6n41mhcnj9zyw1vOAD75uh5JirTLoYzt
         p9N7lL+G9RSsOIBznBpAF7XNSTqQ0z8rQSmNt6Zl6haoHU6DlfXQwsGqbsjd5/IbZjWk
         kMfI6XUblw0FcNsiu1P/NJ127sFuTvtv5qYMsQcALu3fz9vOC4J2iCrdJsJq+IssxNO5
         Q1H4ApT84H2Z1CUsFA235kNR9hIYg2+rGNhndfiKxidzq9incVfVbHQdx5d1sBVlEsmS
         SxI5C8ma+8ZjOQzaGZWFcrutkDnIKvY43NgovyEAYMM48RbMepP8JAhm/rc4orZPwNVf
         RMcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=3cLq+kIlMMXRZaenVxSwc6pfzBM/ls2MR1D4QP0Hu2k=;
        b=zQY6fWOjpvAC2aKFFy8Fk50H7XhtqGXTFqviis1/habD6HELnhYXEzQcaty67IpcGz
         u8bwH0GqF/A3mTSn0QmFUkG0SdVhMLUlEZonv8oWBSbn1N7HpmdmAdTGSNempvjTbdGo
         +Be3WTFVxUjzWUFzMcBJ8b9yKHdyPD7i4mP5R5g5hA055XSA1HnSkqPEjhPTCzWZ3o/B
         SGJhggYLFiCLHK/2UD2yLeqD9gzrHdvO2lktn52s8KWms27M8jDEXlwh73f0TOdjxcBx
         sw++eX0k/66wQpn6F0RUAtA3Q7HYKb2SSV30Mi8ULyhT1RNovk4roD4VFyOND8QrU4LP
         qhSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a26sor9142493vsq.80.2019.02.27.11.27.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 11:27:53 -0800 (PST)
Received-SPF: pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Google-Smtp-Source: AHgI3IYIIgJnnj+3JVj92wdAfbL35gf/TxgoFevJ67043vd71Gt2nCkIM687D/Ouf5eryemB/ak7axdzhzJsiRNvfRk=
X-Received: by 2002:a67:fc9a:: with SMTP id x26mr2797801vsp.166.1551295673138;
 Wed, 27 Feb 2019 11:27:53 -0800 (PST)
MIME-Version: 1.0
References: <20190227170608.27963-1-steven.price@arm.com> <20190227170608.27963-10-steven.price@arm.com>
In-Reply-To: <20190227170608.27963-10-steven.price@arm.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 27 Feb 2019 20:27:40 +0100
Message-ID: <CAMuHMdXCjuurBiFzQBeLPUFu=mmSowvb=37XyWmF_=xVhkQm4g@mail.gmail.com>
Subject: Re: [PATCH v3 09/34] m68k: mm: Add p?d_large() definitions
To: Steven Price <steven.price@arm.com>
Cc: Linux MM <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, 
	Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arnd Bergmann <arnd@arndb.de>, 
	Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, 
	James Morse <james.morse@arm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, 
	Will Deacon <will.deacon@arm.com>, "the arch/x86 maintainers" <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mark Rutland <Mark.Rutland@arm.com>, 
	"Liang, Kan" <kan.liang@linux.intel.com>, linux-m68k <linux-m68k@lists.linux-m68k.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Steven,

On Wed, Feb 27, 2019 at 6:07 PM Steven Price <steven.price@arm.com> wrote:
> walk_page_range() is going to be allowed to walk page tables other than
> those of user space. For this it needs to know when it has reached a
> 'leaf' entry in the page tables. This information is provided by the
> p?d_large() functions/macros.
>
> For m68k, we don't support large pages, so add stubs returning 0
>
> CC: Geert Uytterhoeven <geert@linux-m68k.org>
> CC: linux-m68k@lists.linux-m68k.org
> Signed-off-by: Steven Price <steven.price@arm.com>

Thanks for your patch!

>  arch/m68k/include/asm/mcf_pgtable.h      | 2 ++
>  arch/m68k/include/asm/motorola_pgtable.h | 2 ++
>  arch/m68k/include/asm/pgtable_no.h       | 1 +
>  arch/m68k/include/asm/sun3_pgtable.h     | 2 ++
>  4 files changed, 7 insertions(+)

If the definitions are the same, why not add them to
arch/m68k/include/asm/pgtable.h instead?

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

