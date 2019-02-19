Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6257CC10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 11:04:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22D6A21908
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 11:04:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="k7uJwKfS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22D6A21908
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A23B18E0003; Tue, 19 Feb 2019 06:04:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D3B48E0002; Tue, 19 Feb 2019 06:04:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C3188E0003; Tue, 19 Feb 2019 06:04:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 345B78E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 06:04:12 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id v7so299663wme.9
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 03:04:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=rtGjmKlG9FpDsdh9ZJ8Y8iEVJxSkU5/owmFsijqBtGY=;
        b=cAhKIWo/fWEPiB28pRhD7Afl7DoEI/o1nG2F+YRHaLF6tMKawWpD82YTLL7NhG7S4e
         suASO4Nb7fUXrxA6rqTBqh0Op+D/UmC5fkGJTg0fzkBUxyfbOtrHQ6ireR6ut89ETFKR
         9NHwc9ryv8fmri4D4m2Nw8eqohwOjo5vX4nUkCuB3YGag40jCJtOI/Fcvj9C3CtO7e0i
         xmbcDZ+FENhX690cYTHic29s12gcJPvxc4E3GSxjydi8lWBjiN1gqcYCvmu+8t6gKsyX
         I5uE/mUpchB3ehpJvCn9xH/xHim06DiPk95iFNuO3P8u9PhuHQb/+EiNXSTCntGlin7Y
         7gyA==
X-Gm-Message-State: AHQUAubw2hSauxQ8WHd9SaRY3x58LCfV+1lA+Hz0SN7p6s3aIGPI9X1x
	omTMLnF3Vua6ngPCJpvvsox7tsCnLb0XpfIHdLJt5bugbxYRcPlA2/scBw33lrwA1f4AHiWlu0E
	KejQ+iqJHSGyO7om0e58SK2u6Ls1ddpgTI/am153v/MTQDYOo2Ki/JBhBMWrwC/9Ofw==
X-Received: by 2002:a05:6000:8b:: with SMTP id m11mr19464358wrx.243.1550574251608;
        Tue, 19 Feb 2019 03:04:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iby3knYWUvTM3gihH2sBCeLEUg4uTR/jW/ohSwtMpL8t/Eel4Fp+Cqh6uQXJMIb8UDzyAoU
X-Received: by 2002:a05:6000:8b:: with SMTP id m11mr19464295wrx.243.1550574250705;
        Tue, 19 Feb 2019 03:04:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550574250; cv=none;
        d=google.com; s=arc-20160816;
        b=mtOmy+sft7TWJADza8NQaPNE1IUMKykPzSzl7Enbxqihhuu8glsGNRg+8h/lPqsFYP
         gRjrw8+pc5VtJtF3KJMCWYCD7P+GGPzRY7atL6NJ2FHEMpThrtS9oeZe+0jHM3e3m/F6
         ap7xRk4GpOcZH23pQuR7riEtRMSDBFsKGNBmrAP+uQuD9lDu+tTcSWir8a4WDNsMNpfz
         9uSq1ztQYjIj74t75Oi3uyc9yWN1VUFEsUzS4BpIL6rMKpwQ7FMfQsBmf5CS4TbNx6vg
         eA7jeoV2Hgnbi5JFN58gH2In7ioOJ5DSimIoKkgSvL4yyyqdA8YAJbw5v5LvwOJXxby5
         YQYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=rtGjmKlG9FpDsdh9ZJ8Y8iEVJxSkU5/owmFsijqBtGY=;
        b=DwXz9RoC8p9cSp+MLP+BeRHEZs8Yb7CD7vLt/dEh0+KhwOzfky67nKx+nq1A2lE5aJ
         FzfRHC90KPUDW8eix1LQY0PC3gZZYKzoW6XcFAz/bRnaDwGhtokq2i5a6z1Zny1zLChG
         9ooPzWWsm+0h4+lqs8NGVFhwcW1raoezRae70C3tTf17NFs7BYXuuSz+xC4Wl+iR4bK5
         o8J9sjAb7k/so9fBjYVgwT4d7UGKqEHQox7r5Q66XWUBGebNiwD1tWoSJmC1IvyXOOOt
         BJ5ML4mf37ztJvBLzw0ceg7lh8E5c/TaYAcvjhBQkOLNXUZiJXuFkJb13IvIrpBvUL+G
         hSGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=k7uJwKfS;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id t1si13295840wrs.108.2019.02.19.03.04.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 03:04:10 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) client-ip=2a01:4f8:190:11c2::b:1457;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=k7uJwKfS;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCDC800496980E891B65FF8.dip0.t-ipconnect.de [IPv6:2003:ec:2bcd:c800:4969:80e8:91b6:5ff8])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id C41881EC03D8;
	Tue, 19 Feb 2019 12:04:09 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1550574250;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=rtGjmKlG9FpDsdh9ZJ8Y8iEVJxSkU5/owmFsijqBtGY=;
	b=k7uJwKfS/qVBAXcPfEGBLgv3A66WzfEHKr0s2lHZEeBVWUwoKU8BAMyhWTzqnbNC1YFHzV
	N8q2OYSmYK8mq72Sub7kdxg8x5iSKQ0zqEaG4Gtr/AAeBuKp7+PfA35pk2ektNQWGwfWNi
	3piWSP/0DRhK4Xj7VnSJBRznABaS+sU=
Date: Tue, 19 Feb 2019 12:04:00 +0100
From: Borislav Petkov <bp@alien8.de>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v2 14/20] mm: Make hibernate handle unmapped pages
Message-ID: <20190219110400.GA19514@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-15-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190129003422.9328-15-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 04:34:16PM -0800, Rick Edgecombe wrote:
> For architectures with CONFIG_ARCH_HAS_SET_ALIAS, pages can be unmapped
> briefly on the directmap, even when CONFIG_DEBUG_PAGEALLOC is not
> configured. So this changes kernel_map_pages and kernel_page_present to be

s/this changes/change/

From Documentation/process/submitting-patches.rst:

 "Describe your changes in imperative mood, e.g. "make xyzzy do frotz"
  instead of "[This patch] makes xyzzy do frotz" or "[I] changed xyzzy
  to do frotz", as if you are giving orders to the codebase to change
  its behaviour."

Also, please end function names with parentheses.

> defined when CONFIG_ARCH_HAS_SET_ALIAS is defined as well. It also changes
> places (page_alloc.c) where those functions are assumed to only be
> implemented when CONFIG_DEBUG_PAGEALLOC is defined.

The commit message doesn't need to say "what" you're doing - that should
be obvious from the diff below. It should rather say "why" you're doing
it.

> So now when CONFIG_ARCH_HAS_SET_ALIAS=y, hibernate will handle not present
> page when saving. Previously this was already done when

pages

> CONFIG_DEBUG_PAGEALLOC was configured. It does not appear to have a big
> hibernating performance impact.

Comment over safe_copy_page() needs updating I guess.

> Before:
> [    4.670938] PM: Wrote 171996 kbytes in 0.21 seconds (819.02 MB/s)
> 
> After:
> [    4.504714] PM: Wrote 178932 kbytes in 0.22 seconds (813.32 MB/s)

IINM, that's like 1734 pages more. How am I to understand this number?

Code has called set_alias_nv_noflush() on them and safe_copy_page() now
maps them one by one to copy them to the hibernation image?

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

