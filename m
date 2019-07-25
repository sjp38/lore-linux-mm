Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FF91C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:30:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43EB822C7C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:30:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Rypn7it8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43EB822C7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0BF58E005A; Thu, 25 Jul 2019 05:30:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE3AA8E0059; Thu, 25 Jul 2019 05:30:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD4078E005A; Thu, 25 Jul 2019 05:30:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7673F8E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 05:30:45 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a5so25971728pla.3
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:30:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ld8+YgZexEJtq8qLQ0i1oFk2+2Kl/bXdl+p73DYv/hE=;
        b=Zzq8GDhFb8ESZH0aT8OhZleJOpB/haqgLLXVZie9HWMSCFTXSua6Grt4mZkDAlfJJy
         EvP03rJfTUsKOQ1yPWa+Lv8//674utDPjZSHe6z0TgF5V1vpnK8Ps23nCBnNuy45YQ/X
         k0ygkns3XYBNHlh9ycGahVsGCvazg+UflSrs+Wx3jnNm7sx71YkNNN0oFYUvSEaumXB+
         lku7X1zACI4v6p86a2Q0IUk9zvSMYFN/obCwgsZS4qCSFRGVFk1hmo8XnMDBKeQ/+hzC
         oB91jN/TehU18KVOm1mjgClfGdtrZHXHI5PiyhvbWTaCtECLT5OSzOAe/jai/XjyYl2V
         9QMw==
X-Gm-Message-State: APjAAAV5A2OyRZfHTa4Bn+FmkrIuuo4/WXF6j9CXXY6H5ieMHi2VQzQX
	OCBu97fCgejcTfEi5vc7sg12jYZRqjMzTa/p5t7OQl9b4pCLoXd3rSq+NvpxLNO5Wvsjv3Fgj6j
	i+IfHXhvTCtG7fvB6mmhxofOwAIwFoyt88fyJq+D7+kRQfpISOOE13tU059Slavx2eg==
X-Received: by 2002:a17:90a:bd93:: with SMTP id z19mr93030966pjr.49.1564047045140;
        Thu, 25 Jul 2019 02:30:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0x1FqPVIN9A4qhNJC+RFpMY8pgRINgyCDZiw/Id7v4nS6FNYRsZe/8KdpNnfycVsskd1u
X-Received: by 2002:a17:90a:bd93:: with SMTP id z19mr93030903pjr.49.1564047044364;
        Thu, 25 Jul 2019 02:30:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564047044; cv=none;
        d=google.com; s=arc-20160816;
        b=BAIEPk2iYIP8DaE6evtXFc9PS5DIcYuDvOogA0GpWgXyI4WBP4cIRRveTy/C9ZiMZQ
         wjdF4UXvfKDE1Oit/+ELtOv07RqYHAlXBKCA6+K7fn0xf/s7fxmJwXnHRTaiSo8ZBcoJ
         T/gcTt4eShRwPd7arLHBEZZtB/Rb6Zm7in2GpvXMASCZP9K6hlRtj1m4JGIzURq+WvTO
         ouYkCu1Q+ed9dRDda1ypkQOPudBls3gBST83mUaWAepFLMJvKkYCiWGpyVRUxEJ/l5Kf
         BnVDXIfHkw6jTHj/Ohh9DietZ0XHl56/q4BEu2Y7kuX93Fos+ZUQuCquQAkKnYTYcx55
         TtlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ld8+YgZexEJtq8qLQ0i1oFk2+2Kl/bXdl+p73DYv/hE=;
        b=BE0bH4o5Jzg4vdzIdnXjLD0XSjqHbsaYgHgMhqSLunzGBRfoK0pRL9YLv4zHnjo0B4
         3WDR6E1b3OETz8haZu4C32L4vud46lhggdF3xaUGdDHbWna1T9S4/g2+zhOsdMlnvrTW
         kh+5zRkJDpmvjubV5MROvw7GExV28ClC+TkmuveEgQn26HLOLi8IOw2NiMooarkmAC6M
         jZI38Erix5AoCYKAf3Z6E4vkzePab7cMkq/wC0bqiBU33FUglglzmOh+VQR+vU1gheXF
         OoZzOcmFlds/tDatQQYaJu5n9xhpmThzvXP0gbVOpiDPXdpptZRT545ZTBVqgkmnzv5J
         gp1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Rypn7it8;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o63si15372758pjo.94.2019.07.25.02.30.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 02:30:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Rypn7it8;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from willie-the-truck (236.31.169.217.in-addr.arpa [217.169.31.236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 925062238C;
	Thu, 25 Jul 2019 09:30:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564047044;
	bh=YLT7mc7uWZHnVWRAOXEA35kXHXVmPx8BUd1T5sThOCg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=Rypn7it8Rf260lh0cGgrtQiQ283OFmqpG1lxyuto4Y7QYQbzn6ruYk8uV6NiK7D/f
	 hnNYlr/9QmLq6CPAhKWzSsjmkJC+PNqJTbRH4mEjG8OcRYMPfYeyOTSoxzgJPBd94M
	 9AMwOACsNIfinxPFc3YYJSq3Hk2TY45ShQWw/bTk=
Date: Thu, 25 Jul 2019 10:30:37 +0100
From: Will Deacon <will@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Steven Price <steven.price@arm.com>, linux-mm@kvack.org,
	Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	linux-kernel@vger.kernel.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	James Morse <james.morse@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-arm-kernel@lists.infradead.org,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v9 00/21] Generic page walk and ptdump
Message-ID: <20190725093036.dzn6uulcihhkohm2@willie-the-truck>
References: <20190722154210.42799-1-steven.price@arm.com>
 <835a0f2e-328d-7f7f-e52a-b754137789f9@arm.com>
 <c9d2042f-c731-4705-4148-b38deccf7963@arm.com>
 <6f59521e-1f3e-6765-9a6f-c8eca4c0c154@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6f59521e-1f3e-6765-9a6f-c8eca4c0c154@arm.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 02:39:22PM +0530, Anshuman Khandual wrote:
> On 07/24/2019 07:05 PM, Steven Price wrote:
> > There isn't any problem as such with using p?d_large macros. However the
> > name "large" has caused confusion in the past. In particular there are
> > two types of "large" page:
> > 
> > 1. leaf entries at high levels than normal ('sections' on Arm, for 4K
> > pages this gives you 2MB and 1GB pages).
> > 
> > 2. sets of contiguous entries that can share a TLB entry (the
> > 'Contiguous bit' on Arm - which for 4K pages gives you 16 entries = 64
> > KB 'pages').
> 
> This is arm64 specific and AFAIK there are no other architectures where there
> will be any confusion wrt p?d_large() not meaning a single entry.
> 
> As you have noted before if we are printing individual entries with PTE_CONT
> then they need not be identified as p??d_large(). In which case p?d_large()
> can just safely point to p?d_sect() identifying regular huge leaf entries.

Steven's stuck in the middle of things here, but I do object to p?d_large()
because I find it bonkers to have p?d_large() and p?d_huge() mean completely
different things when they are synonyms in the English language.

Yes, p?d_leaf() matches the terminology used by the Arm architecture, but
given that most page table structures are arranged as a 'tree', then it's
not completely unreasonable, in my opinion. If you have a more descriptive
name, we could use that instead. We could also paint it blue.

> > In many cases both give the same effect (reduce pressure on TLBs and
> > requires contiguous and aligned physical addresses). But for this case
> > we only care about the 'leaf' case (because the contiguous bit makes no
> > difference to walking the page tables).
> 
> Right and we can just safely identify section entries with it. What will be
> the problem with that ? Again this is only arm64 specific.
> 
> > 
> > As far as I'm aware p?d_large() currently implements the first and
> > p?d_(trans_)huge() implements either 1 or 2 depending on the architecture.
> 
> AFAIK option 2 exists only on arm6 platform. IIUC generic MM requires two
> different huge page dentition from platform. HugeTLB identifies large entries
> at PGD|PUD|PMD after converting it's content into PTE first. So there is no
> need for direct large page definitions for other levels.
> 
> 1. THP		- pmd_trans_huge()
> 2. HugeTLB	- pte_huge()	   CONFIG_ARCH_WANT_GENERAL_HUGETLB is set
> 
> A simple check for p?d_large() on mm/ and include/linux shows that there are
> no existing usage for these in generic MM. Hence it is available.

Alternatively, it means we have a good opportunity to give it a better name
before it spreads into the core code.

> IMHO the new addition of p?d_leaf() can be avoided and p?d_large() should be
> cleaned up (if required) in platforms and used in generic functions.

Again, I disagree and think p?d_large() should be confined to arch code
if it sticks around at all.

I don't usually care much about naming, but in this case I really find
the status quo needlessly confusing.

Will

