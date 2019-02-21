Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 826B0C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 14:28:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32B4E20838
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 14:28:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="1W/lKVgG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32B4E20838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4F2D8E0086; Thu, 21 Feb 2019 09:28:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD5B18E0002; Thu, 21 Feb 2019 09:28:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B78448E0086; Thu, 21 Feb 2019 09:28:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5898E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 09:28:19 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id i3so21805511pfj.4
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:28:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=pA9wgCQyEUyTHkAq+rVlPzlBQCV50nMzrf+ehGsqY3Q=;
        b=N6rbGSL1Xtp5qXazl72stW2Qphx9wp+Wz6zROA6NroN7VbcEhPnewAFkXR/9uWqPus
         dEdOfm/OCeTle24l/c6OKk9tbGQttyDVifztb1gQZbGG50bFhdtHM4G4OPd49EaDFdmc
         bbUJn6zW5wv8zCK9o4lFNs0i64qXvV8tzFVrJWKdtI8rxzzRFg6GYxxb5m5PokYEw/ok
         AH4sVEjMVQNUoaUt64Mj7v4AI+XgsVksRksXtNgfIbhnAzz/gc75B0BBQKNwVjUg07jq
         n1T9GHuSGOzs+1tAruMYkIGbrkkRgGl0RLbbwPNtIhrpQWIqsOlVJ27jmciBQ9VICyU3
         EguA==
X-Gm-Message-State: AHQUAubXdQp8nf9VaMTk53kNo2kAlUmf6HkNHrsPE3M6pIVlSD80kW9Q
	l3/BpktDac9SyaL2TFVGeTFaQBNORO4PV21Jd3lm5e9a1fjoEgIRMDIBQ0xcDfn9dVUZSa8Pt7K
	2ZKWJv1rZxtNSTJ0LzO/izS/gg2TspI0xDq6/hYI4s2t6cC1bnN+OCZWWUdLDYKAq4VUA20xzlP
	wv8oMhSVNhy20Osj2iIjoQuaWYzqk7IpspZe2VPnLT6UR+g8cXmZgowzgAcwhSMDYkiC8qEfGAY
	/XwIePj4O1xDDuAOHzi2TXBItInVPmsGSrXGtsbufqW0LFMYFN48n/MvXMJU5uLYYhO7EM/EhPy
	qxN3Y+D7jXG1eEBmf8HniN6XNSJ8Y+ngYo6Mz3vOzSnrm4o+QaiWN5HLF/2HeqBke5txNFS2Kww
	m
X-Received: by 2002:a17:902:7205:: with SMTP id ba5mr31648402plb.255.1550759298978;
        Thu, 21 Feb 2019 06:28:18 -0800 (PST)
X-Received: by 2002:a17:902:7205:: with SMTP id ba5mr31648355plb.255.1550759298334;
        Thu, 21 Feb 2019 06:28:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550759298; cv=none;
        d=google.com; s=arc-20160816;
        b=sgy8w+2ybEvu7tBy06X+5tEvwTPEebcDe1dr0eGJEIz0a87vI7cf07ycVm/V10uRhK
         7WoS1KanvN+DCLqgUvL5unrtnDp8+/F6WYv4ytOH1Pl1JAECSOif5D1NLFVcLQKBbmW5
         3Gq4ET6lstAHZ9Sim7A/C/FqR0/tKXieLjDtMlw6E8yfrpT3IkgsFCEonQ14XXrsW1yH
         iiCJtIik0DHPlI93HU19jLZ9lu82KW4NoFTgCVQqzYXTxD/gFw63olODcPsTA0o4LVzQ
         y1pZzlP144z17/qR4ZzIAQM+dQmJAyV8WLiL/nJrRsg+BukfNe+miOGtoCHPX5fr+a/z
         b0cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=pA9wgCQyEUyTHkAq+rVlPzlBQCV50nMzrf+ehGsqY3Q=;
        b=u/HVXSBjud+JYGGvwUqonRw+mtYl7/Arvg3KJelmcIwCIAdh96P49lGV0FhSeKFozc
         5c1N4tjkfWS3jl6Q0E8cF0AcuZqAi55kkds5QxnlFrb3XFBgG0+PYmGQ4iNRpYxbNx5N
         B/4445vzNeU86Oj0D5ka4yfPFPP6B6/DcLFlHHePN/n/3Zb9c12T88mQ9wyhJqC3wwL6
         ZkjT0sTWiUheKwrGcqGkT0/ne50KbNaDEx7jTrBbF9G3wDB/H6nXIA6niYwfXV7CWdxF
         wlzus8sWRwMPN5JC6qupg9c/XNX4i0fTa00KrQtRMxPzaje2AQyJGApA9AmLtv3fWT7B
         cS6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="1W/lKVgG";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j126sor35720469pfb.64.2019.02.21.06.28.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Feb 2019 06:28:18 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="1W/lKVgG";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=pA9wgCQyEUyTHkAq+rVlPzlBQCV50nMzrf+ehGsqY3Q=;
        b=1W/lKVgGsUokYt6qJwL+oFd6wI/8KbnaSxB0ry6zobjbzzt8lwy3rDM0GPrPbtSzWc
         XG5+mzm8TvRZAvS9RAH1TXfpQzPMGUQl6oFNDC4cI7CFGbnXzzQkKLtKcRg+9PQgPMg0
         pXOIaFUcQmh98dypu8uNF3Y2c/xfQLSZaDJV0dnCRB+kT6gfZqY/nbPnUJ9KfNdArqh7
         gaOhtVDM5gTEAmClFOieev9ao8Ctx/Fy8y8/MqglYraqRqt5rGZzTWciBFhzAHeoA13O
         FAi/fYvXvQljBV62TkgyfrGmaviIfnN2K+pcsmzHfWyWorMknnuXuMfFrqSEyT2WFs7R
         kzTw==
X-Google-Smtp-Source: AHgI3IbfbbYkruivN5aBVqRxR1ViZUHLVAQoi1hsZAsMbsY8Xl1Xpgutyz7rtk/D8d3+HA9SOuSXiw==
X-Received: by 2002:a62:3a01:: with SMTP id h1mr39568542pfa.169.1550759297907;
        Thu, 21 Feb 2019 06:28:17 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([134.134.139.83])
        by smtp.gmail.com with ESMTPSA id y5sm41244867pge.49.2019.02.21.06.28.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 06:28:16 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 0B424301708; Thu, 21 Feb 2019 17:28:13 +0300 (+03)
Date: Thu, 21 Feb 2019 17:28:12 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v2 03/13] mm: Add generic p?d_large() macros
Message-ID: <20190221142812.oa53lfnnfmsuh6ys@kshutemo-mobl1>
References: <20190221113502.54153-1-steven.price@arm.com>
 <20190221113502.54153-4-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190221113502.54153-4-steven.price@arm.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 11:34:52AM +0000, Steven Price wrote:
> From: James Morse <james.morse@arm.com>
> 
> Exposing the pud/pgd levels of the page tables to walk_page_range() means
> we may come across the exotic large mappings that come with large areas
> of contiguous memory (such as the kernel's linear map).
> 
> For architectures that don't provide p?d_large() macros, provided a
> does nothing default.

Nak, sorry.

Power will get broken by the patch. It has pmd_large() inline function,
that will be overwritten by the define from this patch.

I believe it requires more ground work on arch side in general.
All architectures that has huge page support has to provide these helpers
(and matching defines) before you can use it in a generic code.

-- 
 Kirill A. Shutemov

