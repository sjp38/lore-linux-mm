Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDD13C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:30:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C6CD20850
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:30:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="LZiJgMy4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C6CD20850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38C618E0004; Fri,  1 Mar 2019 07:30:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33CCF8E0001; Fri,  1 Mar 2019 07:30:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 204F38E0004; Fri,  1 Mar 2019 07:30:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2A298E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 07:30:37 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id f10so17599509pgp.13
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 04:30:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=GwN29NY+nAlefSDnECPz319uLNHU3cPMNiJ5hS0ECbw=;
        b=ljKpHSPrOXMY+0jU8PkUpsj+9FhVBAQSExW29AvV0GyK659S8DjWQvY9sP6LPuSKvA
         urg9D32JO/kOIJzMDGOMr2SPbfKak95PuuP7J9GNYn+oLpiIrgNIY8+BPvY6WPFb9laq
         pGVelTqkyJuwbKlfbv7QjCbPQr21gdsDtz7UOFP/k+3KdJ6EHczbRkwQhK0gEyYLcEku
         HxVhSleOeIwvey/1AFkjzbAlQZGo4ahV9ba3cxbkw7eDbafL+NXNFZMDHsmIr7JXJkIr
         QN1GqSpkYBgqFpIqgE6xZvnbCFc8CyonU8Z43hFfBJ+1yoPIA1euYxts/9VIdSErCQNl
         l7rw==
X-Gm-Message-State: APjAAAWBrLrGNKEMKT8/ZGNsrBwiJnDCUNYEHEdMtY22hR4nZcPRCqWn
	N0Ly98hDtqikFZSvrDabyIxCv03ZCTje23YT+Q4BKvy/wv6fyUVd2J973MXxRBo/fBgg7ogKuhR
	UKRFPLkTeNiFrT2sx4Q6Z4iCLQ3yKgA7Nv9w5ON1Rmm/5aLIQB/BjNDEXTFrT+pG4EKvubPa0bs
	qN1qCSthF4HQJc3DFNn6njO5R/DzYYbjImYCEa05/+mlDoRd6zo7cFMnNQdOrECM35HkVq1Mul0
	wAmPbu2WxuCKU0BJqZwd1K+d8OXDD4vJHR+i1LQWvvlvC5DDsVbpW8Nvitx8xmmfKt4BuCmIrUW
	P5l/Hlk/aR9+nlvTF0fT7sn5xrG0aAwJ3nJZP8xgGuKqmU4Qh1T9a/zHxtLuFSaqJVtn2w4Suop
	y
X-Received: by 2002:a62:64c6:: with SMTP id y189mr5381348pfb.103.1551443437539;
        Fri, 01 Mar 2019 04:30:37 -0800 (PST)
X-Received: by 2002:a62:64c6:: with SMTP id y189mr5381281pfb.103.1551443436822;
        Fri, 01 Mar 2019 04:30:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551443436; cv=none;
        d=google.com; s=arc-20160816;
        b=nrVAz0PaSZAVP4Or3BAQXQliF6T7mQEGtZksJ7FypF2/ZKuAqCTytTOdYdz9A2jbtY
         uG7QD1/6ji8bALsZxgyfC2/C12ag84b5Fg9FT9wbYXSeVy9w4reeyY5+GDGt8TmVQDRC
         e1NQfIi2JG5hbmNtL+nliSUcgJLy//h3fOPtHKHCxE3Mudtjj3UkY3mbooJbKVioJeWy
         hFc0iOjL9piGSUneMoR6Hu/YqBhNymrLEBJ68awZ/jAH6r/1o1A/OmHNAWldQLu1BN/h
         RG9d8Ogfk41fsQgD692seD3jPeUA0u59Hz3TfoEYmh+uBBoIgsdqFRRy7qV+oy+ln0jZ
         CuWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=GwN29NY+nAlefSDnECPz319uLNHU3cPMNiJ5hS0ECbw=;
        b=ei6zWdqVALKwRq39kf7YqTEpqQY4KpbBIzjej4sGaTN8WqlHO6e4OCKZ8a0j8TKcV8
         zQDHLOhkJBL0boMsBsWbCkA8y+LvYiS3UmdjiUKj7e32YXz33opYvJo0SMJG6Gwkoast
         ZMQBQ6MHAvBP2uQDJvl3phavxtcF9OxRRjUfNNUmkUBPt/ECADFS0BYxHcnMfJ2UeqUN
         Z+O8Uu2XCE7jcXZ7u8IJWKc/U6wXn4S1kCa0R/m7uumk6fS1zr/10mXg8C0/7oWMIC5/
         V/wk5cwELXMSdIgmt16BBA2Vzy1eCCO+nNgwBEGurRmTQfALaQhknMQum6mH4if4Ugil
         Sggg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=LZiJgMy4;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d17sor32443800pll.50.2019.03.01.04.30.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 04:30:36 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=LZiJgMy4;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=GwN29NY+nAlefSDnECPz319uLNHU3cPMNiJ5hS0ECbw=;
        b=LZiJgMy44t947Rdt3vyKczwDk0n+rpmTMgsgz6v3p24vpWEGB2pZKPqmCOGZSz9Ste
         TpE/+XRwj+R8GJj9HNsRGh9aCTAlliu4V3Esj8kgs9fSnR7dVExFnKuu2guEQvQMjRRu
         STq3OlxsJEazLRzI47N8PXPu8aq5IPILTLh7SC326Xzwby8SW4kdAE3qbZ+Un3TDcf7c
         l05wRG6Nju9RxIzUQK3JQq+eMrYX5ZiH+RY8AR9GG3dJ3zEh4bvYIUSX3Q8hdmur9tKs
         x9hVnxmZbKOtKIquWxPFS+gx/KAw+R6pfeXqsO/iuImeNSMTl1a+tMOOMzqk2HsCjj3w
         0PAA==
X-Google-Smtp-Source: APXvYqy6pV25UnwnnU3xX2RrPJ4FcMnfFJ+8Gwik7AdJVp2ntt5m6dL3usGlH10SREOL7aMKG/qKtg==
X-Received: by 2002:a17:902:b20c:: with SMTP id t12mr5219887plr.340.1551443436539;
        Fri, 01 Mar 2019 04:30:36 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([134.134.139.83])
        by smtp.gmail.com with ESMTPSA id z189sm9589765pfb.146.2019.03.01.04.30.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 04:30:36 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 3544C3007CA; Fri,  1 Mar 2019 15:30:32 +0300 (+03)
Date: Fri, 1 Mar 2019 15:30:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Steven Price <steven.price@arm.com>,
	Mark Rutland <Mark.Rutland@arm.com>,
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
Message-ID: <20190301123031.rw3dswcoaa2x7haq@kshutemo-mobl1>
References: <20190221113502.54153-1-steven.price@arm.com>
 <20190221113502.54153-4-steven.price@arm.com>
 <20190221142812.oa53lfnnfmsuh6ys@kshutemo-mobl1>
 <a3076d01-41b3-d59b-e98c-a0fd9ba5d3f5@arm.com>
 <20190221145706.zqwfdoyiirn3lc7y@kshutemo-mobl1>
 <e0c7fc0c-7924-1106-a7a3-fc12136b7b82@arm.com>
 <20190221210618.voyfs5cnafpvgedh@kshutemo-mobl1>
 <20190301115300.GE5156@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190301115300.GE5156@rapoport-lnx>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 01, 2019 at 01:53:01PM +0200, Mike Rapoport wrote:
> Him Kirill,
> 
> On Fri, Feb 22, 2019 at 12:06:18AM +0300, Kirill A. Shutemov wrote:
> > On Thu, Feb 21, 2019 at 05:16:46PM +0000, Steven Price wrote:
> > > >> Note that in terms of the new page walking code, these new defines are
> > > >> only used when walking a page table without a VMA (which isn't currently
> > > >> done), so architectures which don't use p?d_large currently will work
> > > >> fine with the generic versions. They only need to provide meaningful
> > > >> definitions when switching to use the walk-without-a-VMA functionality.
> > > > 
> > > > How other architectures would know that they need to provide the helpers
> > > > to get walk-without-a-VMA functionality? This looks very fragile to me.
> > > 
> > > Yes, you've got a good point there. This would apply to the p?d_large
> > > macros as well - any arch which (inadvertently) uses the generic version
> > > is likely to be fragile/broken.
> > > 
> > > I think probably the best option here is to scrap the generic versions
> > > altogether and simply introduce a ARCH_HAS_PXD_LARGE config option which
> > > would enable the new functionality to those arches that opt-in. Do you
> > > think this would be less fragile?
> > 
> > These helpers are useful beyond pagewalker.
> > 
> > Can we actually do some grinding and make *all* archs to provide correct
> > helpers? Yes, it's tedious, but not that bad.
> 
> Many architectures simply cannot support non-leaf entries at the higher
> levels. I think letting the use a generic helper actually does make sense.

I disagree.

It's makes sense if the level doesn't exists on the arch.

But if the level exists, it will be less frugile to ask the arch to
provide the helper. Even if it is dummy always-false.

-- 
 Kirill A. Shutemov

