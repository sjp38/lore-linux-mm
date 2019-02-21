Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CD05C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 21:06:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AB1D20836
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 21:06:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="NKPNMRo3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AB1D20836
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82DBF8E00B4; Thu, 21 Feb 2019 16:06:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B44B8E00B3; Thu, 21 Feb 2019 16:06:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67BBD8E00B4; Thu, 21 Feb 2019 16:06:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id EE9178E00B3
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 16:06:23 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id c5so4066lfi.7
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 13:06:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=VaJWYAuyQeiGU3BWEwsARtgeEZnMSVA9riqh9x2CWpM=;
        b=NDhha5R/mm5FJsUjuT9CUTTECu9/Jq/SUY6ohwUPM6C7pbxel6EfEaWVI2WpbTPSY7
         67zQ7CwQJmIcQAXGxXe3hlshLr2USkr9cPduWTJwDWDewaCyNS2GSh9r76brkW80K48i
         X2VMtfY/9SDuKCJyWHFU18Q49FBvE3wD1QnaKestiqhR1LqGIwKuw+lQWP4sNMS+RwHt
         k7NDLorIy+EuU31ZkK6jONL36N4J3hn/rmn8MYW71KuS/NnGqT4CLrlyGutPLRsL8sCl
         ozjoU8Fh7PB7kWtgfOYyWxdPfh4kSqZBoxJwkwlRDMd2REzwbNn4b5jO+OVSzsvntSBD
         lGBA==
X-Gm-Message-State: AHQUAuYiVd2sOytFL6kbxuKz71AYMEb7RoS5VmLzA2wNzF07JlPvnsFk
	rbTuZhQ7/w5hmakgi9RFs28efLCtDDLjiyykMuxaLSwlMcbcXrZpSru2DfWQB+AelTQZd9zczTZ
	iHApV1/QjG1nbkjwCr5vR7GeMh2Kstfyg1s/+b/nUgmzdm4f01vV/x123BHAhFV7knYiY8lY59b
	YGok3i6xFo+VosrNqdM/NnVPZZDgn2+iOeRXECZtGt/eCSH1R5L/nxyE9uKo3Ue753iyVm8fqax
	y6Xi1zwqhcLX08AX3qZIg4uOGJuvRz+i2WT+tz5+F+TPXqKexrD9Wk26u7XWCxHYedCZgwAbj/j
	voy3qVLXKPPNaT0iqYilLa1eigbGWKvfPE8mceXfJdWodqAqPU85HQMYhc3XRH3xmCv2eoHHG9r
	Q
X-Received: by 2002:a2e:9618:: with SMTP id v24-v6mr292816ljh.110.1550783183152;
        Thu, 21 Feb 2019 13:06:23 -0800 (PST)
X-Received: by 2002:a2e:9618:: with SMTP id v24-v6mr292780ljh.110.1550783182073;
        Thu, 21 Feb 2019 13:06:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550783182; cv=none;
        d=google.com; s=arc-20160816;
        b=RLcod/c+FENouX3iqMLtrQxwa8OrEDxpaLDlvXhyTAGLlK0i+Xjps23v6e59dwYbYe
         iaF1PgdJqDF+Z18+dVP0WgTzyV2XrBVasogFOIEtgPL3wF2hVa3WotJNSitOunyUBYab
         FaM3opVvWt8ycnY+0SGzC5Zr1FWaJoTHyOBAA5qIkDcIFK45nshONke2d4uSD9QmUXWK
         byMSxmuvoxUFnnJcDli/lhePi29YoxNeIMsrHw6a9/JK0oQEa80N/d0VLP4212pSo7Tj
         LmjiKevQTSGIRQoEv33gLjQSmo+H31i4hMV3tB8F6oHfp2H6PMsuNntQbVcEEUYfjbSq
         SF2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VaJWYAuyQeiGU3BWEwsARtgeEZnMSVA9riqh9x2CWpM=;
        b=l5JlkSLa4zlUL75JJEkVlCF4yZ43mmjcKI/0bxKFw+By9461Syx68o1kQZhCvdvCTR
         JnylBhG0aGJp+eUIKxDA+c7txI8SS/CUENRahZVx0xTgnzu1IR7cshKCWMGa9YV75NTc
         eQxoc2r2Uq9nnwDI74SomVZZdsbFuHSuRuFCCpfk0lJrB+kbUCEESyLhiIC8RNjNzKMi
         M1Nj1Nc3t+ybIKMZ/7MoWZavYqtX0vzkQA12Aze72iIaCDC0sFEy5ev9ndKtcrgPtIiJ
         4aaWPMsxtbI3PG8LFwscC9ZApM7285DRgR0GPieMqrmakp6gQIsopWZhHCDUs1PtKd6c
         xOUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=NKPNMRo3;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t5sor6699829lfd.71.2019.02.21.13.06.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Feb 2019 13:06:21 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=NKPNMRo3;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=VaJWYAuyQeiGU3BWEwsARtgeEZnMSVA9riqh9x2CWpM=;
        b=NKPNMRo3ErcDG4ky/fPBEzQnksX3jp49gQoP5BNMEml3Xa4+q8OBDs7eAYPRL6qIaa
         YnxzxJBtMWzo0qktAuwG5l6TasJiZlpxVYcujUQeC9ZyBOy31eoJP2BEWav5d6MVOWFT
         ih1drWY0aq4VUyqJizrEh6aOe04fRSqfb/3/vv8pOVYQ7XigqKstevSLa4l2aF42wYPT
         KkNfHtJMkZH4omVe/xjOwvs0Oo/DxPn8TwLXZrI3EbTeppnTN0jFJG0j/9bVHyOeAA6v
         LYgZf4FpipElkeU0YNCJqUuOwJL3/b6ZeZT+gWOK+CkI4MM2RS0pxYuSWRnBJkwbSBGq
         etsw==
X-Google-Smtp-Source: AHgI3IZPyEOrLA7QJzleHCFDOD1gvwBgGn5TGNiVcau/7k1voltB6KSCgJi+MGXiUxUSeuln6x/iYw==
X-Received: by 2002:a19:6001:: with SMTP id u1mr317237lfb.56.1550783181385;
        Thu, 21 Feb 2019 13:06:21 -0800 (PST)
Received: from kshutemo-mobl1.localdomain (mm-23-232-121-178.mgts.dynamic.pppoe.byfly.by. [178.121.232.23])
        by smtp.gmail.com with ESMTPSA id z85sm6143768lff.80.2019.02.21.13.06.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 13:06:20 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id E14B7301708; Fri, 22 Feb 2019 00:06:18 +0300 (+03)
Date: Fri, 22 Feb 2019 00:06:18 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Steven Price <steven.price@arm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org,
	Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	James Morse <james.morse@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-arm-kernel@lists.infradead.org,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v2 03/13] mm: Add generic p?d_large() macros
Message-ID: <20190221210618.voyfs5cnafpvgedh@kshutemo-mobl1>
References: <20190221113502.54153-1-steven.price@arm.com>
 <20190221113502.54153-4-steven.price@arm.com>
 <20190221142812.oa53lfnnfmsuh6ys@kshutemo-mobl1>
 <a3076d01-41b3-d59b-e98c-a0fd9ba5d3f5@arm.com>
 <20190221145706.zqwfdoyiirn3lc7y@kshutemo-mobl1>
 <e0c7fc0c-7924-1106-a7a3-fc12136b7b82@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e0c7fc0c-7924-1106-a7a3-fc12136b7b82@arm.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 05:16:46PM +0000, Steven Price wrote:
> >> Note that in terms of the new page walking code, these new defines are
> >> only used when walking a page table without a VMA (which isn't currently
> >> done), so architectures which don't use p?d_large currently will work
> >> fine with the generic versions. They only need to provide meaningful
> >> definitions when switching to use the walk-without-a-VMA functionality.
> > 
> > How other architectures would know that they need to provide the helpers
> > to get walk-without-a-VMA functionality? This looks very fragile to me.
> 
> Yes, you've got a good point there. This would apply to the p?d_large
> macros as well - any arch which (inadvertently) uses the generic version
> is likely to be fragile/broken.
> 
> I think probably the best option here is to scrap the generic versions
> altogether and simply introduce a ARCH_HAS_PXD_LARGE config option which
> would enable the new functionality to those arches that opt-in. Do you
> think this would be less fragile?

These helpers are useful beyond pagewalker.

Can we actually do some grinding and make *all* archs to provide correct
helpers? Yes, it's tedious, but not that bad.

I think we could provide generic helpers for folded levels in
<asm-generic/pgtable-nop?d.h> and rest has to be provided by the arch.
Architectures that support only 2 level paging would need to provide
pgd_large(), with 3 -- pmd_large() and so on.

-- 
 Kirill A. Shutemov

