Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D69BC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 17:06:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA89F2064A
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 17:06:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="ATn+ZtuV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA89F2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4ECA08E0004; Thu,  7 Mar 2019 12:06:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49A958E0002; Thu,  7 Mar 2019 12:06:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 362DE8E0004; Thu,  7 Mar 2019 12:06:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id D1EDC8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 12:06:28 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id f4so8808769wrj.11
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 09:06:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=l8cTM4Q9P0s3RXZNsCWcgbO0ogkOlG4bqVEytx8DQK0=;
        b=NuIm3oL6oo5PgG724gPdzGNMZQzlhhPRjAJ1ZHkCDhNKvuNot9M+ggKfG5hzDznyNt
         AjdhaVm6CV9PUTmzp2PNqZbSRzO3j/glu2C9Aem8bGhdQrXSSbRoB8XMJXbN86dNbZHt
         c0y32a18nOFgCKJUqt9Ja59iP9oezH0LK/PSzomW0P4wNZjE7Ql25WJawVQk46Uni/vW
         J7ctXUM4bmbWazU1Hv/JuUTfebDsmeSDO/fUPI4hhnWeDKltw2JuVcBDlA1o3vckm4d2
         3XgxdxDKyy9tCGyxw75Dd0JIKqfrV56FoQbH/fJDXu3mXu55uGWvqjpYfczJ60QpH6fx
         EzsQ==
X-Gm-Message-State: APjAAAVmXXCAkFGg6S7Q5oLiRLMNLGvCboCZk4/m7tRWPXm5Ib5Srt2F
	7Cafz/fuOlbxUeN1Y5Dwy+/5pJHKLAeqfrzrJzQQg30V3YQITRXGfKppaA9dlU0fTKXbHT901Fz
	qZnZs4Je9gBLyRAM2NUdWcLmILmL+zq23cWKBeg5jClw+FNfGirFGHFTZ3EEuNIQDlg==
X-Received: by 2002:adf:f410:: with SMTP id g16mr8010057wro.246.1551978388338;
        Thu, 07 Mar 2019 09:06:28 -0800 (PST)
X-Google-Smtp-Source: APXvYqw/SEW7aXJTMO2vDvxBl+6jlJ0Rc6D0akiEXZyTKUC7K2W6YkAc/fmvV62c+fjPctj6IlaL
X-Received: by 2002:adf:f410:: with SMTP id g16mr8009991wro.246.1551978387314;
        Thu, 07 Mar 2019 09:06:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551978387; cv=none;
        d=google.com; s=arc-20160816;
        b=sMsA4j/MzeVCdsiJHbfziaIGBiWUaaBBQ7euDtydabDhG35+j9nC7PIjrfZs6Sj6yM
         lYnz97DfA9d6TvAcCmzKjlIssJqi8A5xxhKpJvHpdJBVzG9SK2vhtrWeH4cCM9ieOq1R
         6eqhTGZVzCTmccrpfQ0Vy25DPPOYIme8JghTP93rEizWz447V623746l8z+jb0LVpaN9
         Pf3WxUjN6VS8HEkNiHVXTZ+OsRd0uHp+6biko4WVC91mGh11OfVOWTyceeg85ZFgyAMd
         k282an1iM0OrXbPLcSNoZ5wNqY2BJhlDwnBM0vAwLPTrtwB7WUYMgcPZBeLbRjg8ARJB
         TNyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=l8cTM4Q9P0s3RXZNsCWcgbO0ogkOlG4bqVEytx8DQK0=;
        b=Bh8IRLxrskKC/WR+AIfdjjLdh6t1cOK+2xQDpgEOciTwtcFE8F2JSm6ryrHgNPODQ0
         rASdUEy2nXgUkA9yYa/UX/InFsdyXmfGUrvHlFabnY3lRwxThmz9B5UoHPGB169999Fo
         Tx3jwhMYvMDSkVEOt/NLAYwIs69YSqcE+uMaYHJ/pFsYA/fUsTP2lkkQ+EccLqveAess
         suyD86+TD9Rf9TOXq8EBJ14R1q2mJT5hhBrrI6NfdVqmBUuX/lgZ1mkQqQnOEeEoLsNu
         bDFKmZM2F1GdQXpu1oV6H9HXgbMrvLFD3aT0dOb1bzAV6Ym6pQgSE+9eONR0hBYizNPs
         N0UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=ATn+ZtuV;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id b1si3297299wrx.350.2019.03.07.09.06.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 09:06:27 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) client-ip=2a01:4f8:190:11c2::b:1457;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=ATn+ZtuV;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (unknown [IPv6:2003:ec:2f08:1c00:329c:23ff:fea6:a903])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 79C761EC066F;
	Thu,  7 Mar 2019 18:06:26 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1551978386;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=l8cTM4Q9P0s3RXZNsCWcgbO0ogkOlG4bqVEytx8DQK0=;
	b=ATn+ZtuVU+ClpyQgBAKOuZpfBSy9/Dx5UMED9ml4h113elugzb1qFn7lbGNrpfnfie8mmC
	aoP9aXiU+zgnRgI9OpXbhrqrFnO3PsdxLF9jaXXCA2oBndyvQzd6FYW3H78uhFnwXocnhf
	XncZ0ieSiRYL2PGhG+PbQZvyAnmQfM8=
Date: Thu, 7 Mar 2019 18:06:29 +0100
From: Borislav Petkov <bp@alien8.de>
To: hpa@zytor.com
Cc: Nadav Amit <nadav.amit@gmail.com>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Damian Tometzki <linux_dti@icloud.com>,
	linux-integrity <linux-integrity@vger.kernel.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>,
	Linux-MM <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Kristen Carlson Accardi <kristen@linux.intel.com>,
	"Dock, Deneen T" <deneen.t.dock@intel.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH v2 10/20] x86: avoid W^X being broken during modules
 loading
Message-ID: <20190307170629.GG26566@zn.tnic>
References: <20190129003422.9328-11-rick.p.edgecombe@intel.com>
 <20190211182956.GN19618@zn.tnic>
 <1533F2BB-2284-499B-9912-6D74D0B87BC1@gmail.com>
 <20190211190108.GP19618@zn.tnic>
 <A671F14F-3E03-4A97-9F54-426533077E0C@gmail.com>
 <20190211191059.GR19618@zn.tnic>
 <3996E3F9-92D2-4561-84E9-68B43AC60F43@gmail.com>
 <20190211194251.GS19618@zn.tnic>
 <20190307072947.GA26566@zn.tnic>
 <EF5F87D9-EA7B-4F92-81C4-329A89EEADFA@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <EF5F87D9-EA7B-4F92-81C4-329A89EEADFA@zytor.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 08:53:34AM -0800, hpa@zytor.com wrote:
> If we *do*, what is the issue here? Although boot_cpu_has() isn't
> slow (it should in general be possible to reduce to one testb
> instruction followed by a conditional jump) it seems that "avoiding an
> alternatives slot" *should* be a *very* weak reason, and seems to me
> to look like papering over some other problem.

Forget the current thread: this is simply trying to document when to use
static_cpu_has() and when to use boot_cpu_has(). I get asked about it at
least once a month.

And then it is replacing clear slow paths using static_cpu_has() with
boot_cpu_has() because there's purely no need to patch there. And having
a RIP-relative MOV and a JMP is good enough for slow paths.

Makes sense?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

