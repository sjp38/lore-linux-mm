Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 452E1C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 21:39:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3E8B218D4
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 21:39:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=armlinux.org.uk header.i=@armlinux.org.uk header.b="eLpLsIpH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3E8B218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=armlinux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D83F6B0006; Thu, 25 Jul 2019 17:39:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 889138E0003; Thu, 25 Jul 2019 17:39:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7785C8E0002; Thu, 25 Jul 2019 17:39:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9BB6B0006
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:39:32 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id 17so10406642wmj.3
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:39:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent:sender;
        bh=Kavq+eip1im675O4/bBLmRIQNPqz1C3eZxq/uo8ufXg=;
        b=LrhSjeC2nbCnVDU6ir/gNh2Wt9VGjtxO7DEAdJNZACpqY/OQDJyuB/CKwiRGhdNI+2
         wu83uPIBT1WRRlBtEn/nZsf66GPPc4/Cm+1odXJJBZfJ5J1dp0wNL1qN4AsOs0S3ISpE
         K7mbWfz57ukfjZwDR4gST4srFSXgQ2BJ9wYAs105zsK3nCXQI8jHmkvSjOCkrK6K6RNE
         zAFoO87FBl01HHSbFaLBvHDINkX1HX8lOvxAPAfV6ziyx4/El0IiyYQt5+scDfP/bNJG
         ZMYGCK/h8PX2TuvZY6KDLjXuvxXODLbgaupcdLq6DCmewOXtyYpQ7z3eQzQSCwxqQ3/C
         6wxA==
X-Gm-Message-State: APjAAAXwGAM1MV0inVJ4FUZv4JzEeZDO48D4rIl/X52qrudpc0PSTZUS
	klfkngwfoU3FO2jKsG/MOdFodzx00iSmuyvch+znJKJYVF4FxqrE1dk+bZPcwxPXYwW6xkpAtPm
	BVaDRtcAd36no/zqqAk+wsMVbYm3feZPw7rKMSJHP3/88G+z0KCqZnyaDpfLMkaPCow==
X-Received: by 2002:a5d:5303:: with SMTP id e3mr16700195wrv.239.1564090771685;
        Thu, 25 Jul 2019 14:39:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/aSOZoNmOy0XZtIicXQpVD/Bboj+DR11sStKSQrUZaAkqFTAlOqhmtPbQzevcpD0fhKj8
X-Received: by 2002:a5d:5303:: with SMTP id e3mr16700162wrv.239.1564090770927;
        Thu, 25 Jul 2019 14:39:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564090770; cv=none;
        d=google.com; s=arc-20160816;
        b=k7DTE0qqOtqbWyBax8Bg6So56K2jIh+4mESwXITOxbiG8FpD3jpd9DvWiJT/8kWMH7
         THm0AuOyz9HpnxzQAlfdhm91RBjvRCiOnp1A1/DnsKl+2q4GKhjucXtz2Iydphddp3sM
         VYzPsYEr2FA9TiNjnNkxFUeaXzjnB/NGO4fHtjZkcrSOO7vqZvEh39O9Fk11xDe6sRlN
         zmLsY5ywvfmI7FfE+oCcTk6AQXs03SrfZ8JkQGpJof6JBwwL7V9nEcFff7KATIOIycsF
         hB/YNvENkhxmD8bOtorHxA6x0wvK/PPOBekiWdJd4XlqQXEzzSAfaOplq52mCZD9dPP8
         FnyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date:dkim-signature;
        bh=Kavq+eip1im675O4/bBLmRIQNPqz1C3eZxq/uo8ufXg=;
        b=YyC/qoOo0++lythSVzpT46Oy3WYTKPOvjAoB1E76Kz/btWgrsFLg3VF1ofQM6bmv+f
         B1Q8Rkm6vfW/ZKajr9zpbrjUYiPie+dWxMJ+D56LqJHoNJ/8NzSaZe1kuIgzcu3bD/xn
         T2CHOvBKd46uRoJyMgttCYPNlHQBZMbvR6AJCvapNofzjuRS5WHf4oXzfvXKId4z5FJ0
         uj25xUOQ+d5ebi5TMMG+q3FFssNd0468GU5UrQ/vY9RB+LdAEtCX8bDRiA5vNpT9979n
         CztDkhVvJKhjXlTFUeFiJVRuDcPY/DLxqXj1126WwkkrXYpL6OcFug75pTVTLof8O4du
         pJdw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass (test mode) header.i=@armlinux.org.uk header.s=pandora-2019 header.b=eLpLsIpH;
       spf=pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) smtp.mailfrom="linux+linux-mm=kvack.org@armlinux.org.uk";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=armlinux.org.uk
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id y68si13404333wmc.183.2019.07.25.14.39.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 14:39:30 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) client-ip=2001:4d48:ad52:3201:214:fdff:fe10:1be6;
Authentication-Results: mx.google.com;
       dkim=pass (test mode) header.i=@armlinux.org.uk header.s=pandora-2019 header.b=eLpLsIpH;
       spf=pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) smtp.mailfrom="linux+linux-mm=kvack.org@armlinux.org.uk";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=armlinux.org.uk
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=armlinux.org.uk; s=pandora-2019; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Kavq+eip1im675O4/bBLmRIQNPqz1C3eZxq/uo8ufXg=; b=eLpLsIpHT3C0NpVJISxE4wDFP
	0m9PzZxBOyaV1z++UwBohppQQiDGlRoxJgo8tE7vvbhAe0pv+aRmtEdRR79cc8X1YcIrIpfQrmeyO
	EFzavlvQKFeMAPS54eto2mb6JhC0HxzSj38xaLArlIOk7NxOpTKvVDSbeKuD03Mli22Mu7hNeqZEM
	SkZ6oXyf3A+yKcqm6Xk45/zIAP3YQV3zX7VmOauPyiBxJ5XH1H9lcgUkMY/B0Erq2DOy/5UdosSfp
	hkRP/vFoPTpMcJI4fOfZhjaZwLZ24C3sKtAqcajQ7tHjWA6lfmcEN/ctpkjvb6ZeQNA7U/yIjfXDq
	6W1P95aSw==;
Received: from shell.armlinux.org.uk ([2002:4e20:1eda:1:5054:ff:fe00:4ec]:44656)
	by pandora.armlinux.org.uk with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.90_1)
	(envelope-from <linux@armlinux.org.uk>)
	id 1hqlS8-0002Sy-46; Thu, 25 Jul 2019 22:39:08 +0100
Received: from linux by shell.armlinux.org.uk with local (Exim 4.92)
	(envelope-from <linux@shell.armlinux.org.uk>)
	id 1hqlRy-00061g-Ob; Thu, 25 Jul 2019 22:38:58 +0100
Date: Thu, 25 Jul 2019 22:38:58 +0100
From: Russell King - ARM Linux admin <linux@armlinux.org.uk>
To: Matthew Wilcox <willy@infradead.org>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Sri Krishna chowdary <schowdary@nvidia.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, x86@kernel.org,
	Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org,
	Steven Price <Steven.Price@arm.com>, linux-mm@kvack.org,
	Mark Brown <Mark.Brown@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [RFC] mm/pgtable/debug: Add test validating architecture page
 table helpers
Message-ID: <20190725213858.GK1330@shell.armlinux.org.uk>
References: <1564037723-26676-1-git-send-email-anshuman.khandual@arm.com>
 <1564037723-26676-2-git-send-email-anshuman.khandual@arm.com>
 <20190725143920.GW363@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190725143920.GW363@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 07:39:21AM -0700, Matthew Wilcox wrote:
> On Thu, Jul 25, 2019 at 12:25:23PM +0530, Anshuman Khandual wrote:
> > This adds a test module which will validate architecture page table helpers
> > and accessors regarding compliance with generic MM semantics expectations.
> > This will help various architectures in validating changes to the existing
> > page table helpers or addition of new ones.
> 
> I think this is a really good idea.
> 
> >  lib/Kconfig.debug       |  14 +++
> >  lib/Makefile            |   1 +
> >  lib/test_arch_pgtable.c | 290 ++++++++++++++++++++++++++++++++++++++++++++++++
> 
> Is this the right place for it?  I worry that lib/ is going to get overloaded
> with test code, and this feels more like mm/ test code.
> 
> > +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE
> > +static void pmd_basic_tests(void)
> > +{
> > +	pmd_t pmd;
> > +
> > +	pmd = mk_pmd(page, prot);
> 
> But 'page' isn't necessarily PMD-aligned.  I don't think we can rely on
> architectures doing the right thing if asked to make a PMD for a randomly
> aligned page.
> 
> How about finding the physical address of something like kernel_init(),
> and using the corresponding pte/pmd/pud/p4d/pgd that encompasses that
> address?  It's also better to pass in the pfn/page rather than using global
> variables to communicate to the test functions.

There are architectures (32-bit ARM) where the kernel is mapped using
section mappings, and we don't expect the Linux page table walking to
work for section mappings.

> > +	/*
> > +	 * A huge page does not point to next level page table
> > +	 * entry. Hence this must qualify as pmd_bad().
> > +	 */
> > +	WARN_ON(!pmd_bad(pmd_mkhuge(pmd)));
> 
> I didn't know that rule.  This is helpful because it gives us somewhere
> to document all these tricksy little rules.
> 
> > +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
> > +static void pud_basic_tests(void)
> 
> Is this the right ifdef?
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 

-- 
RMK's Patch system: https://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up

