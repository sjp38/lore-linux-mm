Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA0C1C4360F
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 13:11:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DDC520835
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 13:11:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="sddgU2aR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DDC520835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C22A88E0003; Mon,  4 Mar 2019 08:11:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD3778E0001; Mon,  4 Mar 2019 08:11:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE8F18E0003; Mon,  4 Mar 2019 08:11:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6AC398E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 08:11:01 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id e5so5262708pfi.23
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 05:11:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=i+uJsIH9vVyOV5Tk28y23klIfxYci68lEiPowiIlx3E=;
        b=UDHQ0ZYz659qDJTzFbS3uk11A7GLbiQ+smXXc/eLgGdu242r4OHt2zO57SFNLmkm52
         nxPTeag83sQnfSOaMcFENlWN+/Y6F1RQr29yJDjO9EIiag+CJrsb7MPgOkyDC7iWrR9y
         oTtoidaf96Ukb6ABidoKYjJkR7rSlAALn3aFgknFPOBsepNyQGSlqgIer+wXHeEQ7siH
         am/sqM+uFGjiNHL54//YfJPCXuKd/7Crsn8MU3HUMCnHBnrPT1Mu/x2HX3VljvAJBC3P
         dIqurmBNfNdaKHM4c0nPsaHT61W+0Cz5j9LFDT6AeBF14FscKrx1u5kEKfIA5/RvW8yQ
         n91Q==
X-Gm-Message-State: APjAAAXdaBs1iIIlIhly5rNlZmB+XOSW6PN7QKHtF0KCbacyyZBJh2bJ
	tXlZpHAdUtcs6z0NrNABiM67I88kdPGroezWwprNr2QbQ0QHbSqBqHkdOHzzXqW7Qrvw+kPs20Q
	+0Yd/TRkaf4J8c5npCDtRmLsZQ2j/VKWNtTidVykg2gYgLEpZry95y1Jv2w0CUBV/zBsLqngR4c
	xo0MY1CbNzO4MoYHdGte4FJ1jP30hPSblR1jsUG6hF3nEtjXu3y/l/Xdo5vBdx+KRGMYUBLXsHb
	3lc7Kn9ubnX/liqVSSavD7E3WICCKQyuKo9emZWvMYI7pWsKdatKqtOMOtyMmYGRxiHnonweIC3
	/+TNwj2ZgkNXgRHx+u6I8CGZ28FN9dTbmOnP/oH7OM2mk39/+544cEMvuY6myOjhsW79XQUycCc
	C
X-Received: by 2002:a62:ee0e:: with SMTP id e14mr19956052pfi.201.1551705060802;
        Mon, 04 Mar 2019 05:11:00 -0800 (PST)
X-Received: by 2002:a62:ee0e:: with SMTP id e14mr19955971pfi.201.1551705059476;
        Mon, 04 Mar 2019 05:10:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551705059; cv=none;
        d=google.com; s=arc-20160816;
        b=By6fu/HgbF40c2lBhSkojsCZeYq2oCmtydWjGA0Ostw4a9xH2Vf2iYodfARy2xE6r0
         sucSOuGRWy8h4VLQd+NNIVBG9F0ex3PUiTFOm0RFP+XIazI6vs4RbFwdRFDbg4wOnP/x
         +L9WIZY9wOEGCyebB+dWsTdpPgfcBNgon2VX3LsftaeHkh4/om23C76HUsRFbslYg9Lj
         H1cKTHuiHpNzr3eBo4X58zGV3+dxlO3K5fLIhk1nD3tDb6jFphCGSUeMWh1no3IvoX1C
         inyWbEhQpmC+HuQzxgrmrdT67NxhYFe4lXJTm8x1dwQwHIOipHo0PjCwwjQ4HMxywCcc
         JYvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=i+uJsIH9vVyOV5Tk28y23klIfxYci68lEiPowiIlx3E=;
        b=ZvJYhFDyxFQ2ff8K39qVBB9niMgyoZWUXeUJP3Hq8Atjul6UAb6L+2uLhy0J4IrlGZ
         rceQUO4eSles7ipYNvRziRroEioodDbge6lTA0RQT0iBChcRDFstnqFyA/XwlXSSLpwq
         bP8+Ls02W1roQWnhmdulVWUgsVWft08CgD2FvX99PvsYApYIglsAvhzu3fKzcYpNs9Vm
         rDBW8R84Eoe844t8FRGFCj+phUWY7M2g5axPDu8R3qchGYflHSTxlSGIMvDNjk+AJTMo
         z63WQ/ReQwgbF/sj0/Wjlyn43XTJX8iHP6wq9jRSvaKc9+JzChBAbkNE9ysHURJVuPfZ
         D//w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=sddgU2aR;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor8738646plo.49.2019.03.04.05.10.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Mar 2019 05:10:59 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=sddgU2aR;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=i+uJsIH9vVyOV5Tk28y23klIfxYci68lEiPowiIlx3E=;
        b=sddgU2aRtJ2zYqDNcOUZzUk3M/eU6C/dPxzI/yarFrk5YXqKXTlkj9+V6Ej1gWGl5S
         0Y00j8efBGBPNa38B9fwNBevPWrW4bRQn/oqwpPZl2mEOu7VDUlL2/NWR7kGcp/8ayOP
         N0WFcpQyvsiYdHTddw0D88Z+w4eW1PNS5EVEa0YW+pdelsy46Nk5okbwiL+l56G1rLRp
         29tRCiS9Q840vVihdOrq3YC8lfunYrw3EvcMZxWUyrk195VG02sK+7l5nCxai5WslBOr
         mtj248N5e1raENfLI4cliIs/J1DmKCHFfC8aLYUNyNcKMYIUGSOidPjGzeTm7Brf/ltu
         pTEA==
X-Google-Smtp-Source: APXvYqzHr+bDim597mkyh4dboXKIfYc7NYQ38mxKFIYbp8RFyPZGLKWjB/Fag6abhRGxq7b6vqo/4Q==
X-Received: by 2002:a17:902:9a48:: with SMTP id x8mr13344843plv.98.1551705058879;
        Mon, 04 Mar 2019 05:10:58 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([134.134.139.83])
        by smtp.gmail.com with ESMTPSA id 20sm8185700pgr.80.2019.03.04.05.10.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 05:10:58 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 72ACC300429; Mon,  4 Mar 2019 16:10:54 +0300 (+03)
Date: Mon, 4 Mar 2019 16:10:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Steven Price <steven.price@arm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
	Russell King <linux@armlinux.org.uk>, linux-mm@kvack.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	James Morse <james.morse@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-arm-kernel@lists.infradead.org,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v3 03/34] arm: mm: Add p?d_large() definitions
Message-ID: <20190304131054.goxpqsosolkg7khf@kshutemo-mobl1>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-4-steven.price@arm.com>
 <20190301214715.hyzy5tevvwgki4w5@kshutemo-mobl1>
 <974310a0-0114-9a0c-9041-4e0394c4b9aa@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <974310a0-0114-9a0c-9041-4e0394c4b9aa@arm.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 04, 2019 at 11:56:13AM +0000, Steven Price wrote:
> On 01/03/2019 21:47, Kirill A. Shutemov wrote:
> > On Wed, Feb 27, 2019 at 05:05:37PM +0000, Steven Price wrote:
> >> walk_page_range() is going to be allowed to walk page tables other than
> >> those of user space. For this it needs to know when it has reached a
> >> 'leaf' entry in the page tables. This information will be provided by the
> >> p?d_large() functions/macros.
> >>
> >> For arm, we already provide most p?d_large() macros. Add a stub for PUD
> >> as we don't have huge pages at that level.
> > 
> > We do not have PUD for 2- and 3-level paging. Macros from generic header
> > should cover it, shouldn't it?
> > 
> 
> I'm not sure of the reasoning behind this, but levels are folded in a
> slightly strange way. arm/include/asm/pgtable.h defines
> __ARCH_USE_5LEVEL_HACK which means:
> 
> PGD has 2048 (2-level) or 4 (3-level) entries which are always
> considered 'present' (pgd_present() returns 1 defined in
> asm-generic/pgtables-nop4d-hack.h).
> 
> P4D has 1 entry which is always present (see asm-generic/5level-fixup.h)
> 
> PUD has 1 entry (see asm-generic/pgtable-nop4d-hack.h). This is always
> present for 2-level, and present only if the first level of real page
> table is present with a 3-level.
> 
> PMD/PTE are as you might expect.
> 
> So in terms of tables which are more than one entry you have PGD,
> (optionally) PMD, PTE. But the levels which actually read the table
> entries are PUD, PMD, PTE.
> 
> This means that the corresponding p?d_large() macros are needed for
> PUD/PMD as that is where the actual entries are read. The asm-generic
> files provide the definitions for PGD/P4D.

Makes sense.

Only additional thing worth nothing that ARM in 2-level paging case folds
PMD manually without help from generic headres.

I'm partly responsible for the mess with folding. Sorry that you need to
explain this to :P

-- 
 Kirill A. Shutemov

