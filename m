Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57961C43219
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 13:27:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16BC92075E
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 13:27:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="T9s51+W+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16BC92075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B9326B0003; Fri,  3 May 2019 09:27:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86B0C6B0005; Fri,  3 May 2019 09:27:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 780446B0006; Fri,  3 May 2019 09:27:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 41F136B0003
	for <linux-mm@kvack.org>; Fri,  3 May 2019 09:27:39 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h14so2963865pgn.23
        for <linux-mm@kvack.org>; Fri, 03 May 2019 06:27:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mkGg1i+EI0XU//yFAO+gJW+bQDnnQU83x/RNkUevVAw=;
        b=EaatjYjcKIOHQ/ka1k2Ann3f/fzmw5JFkF9GI+ZVPafCriutK3+EIoQsrFpiZu+xOs
         dTNDCYW345BfIFMenNvWtmEyw5+5WEE1XtL5Eyys8ZroDpF9pQA064RGhBngU2bo+McN
         gJ+yUJChurXV4knJ1Jfqo7cMCokK4EK4f63u3qpglW+97T7LWxNS9p4MLM8aoeiKvg0Q
         fZdEhmzGVCdSytf510UbEmD5sdJtwvdwkRnjJdiyecsPP0k8WGMryIXzyIZlqQz4Chpm
         IOL1HBNTc5uwp8DY1O3VnN113+LvPS8alXjwCpZyIpdzmHqEXTuSp6N7D4YS0wlg0NFn
         Wu7g==
X-Gm-Message-State: APjAAAXcKNfb8xoy5XvccUmEr/i4df5Sgt/Pr3YYbm7nkAxAYYjT78H9
	jEIdob9GwVfo/kPk6EK0ZkqEhPiRJjnLLi6Lwt4KxOAgKmE2cODBShubT+jFczwKQD0dcLox7Q2
	iHkcZEqnc72MrM8FzP9Pgwzha5vytLrrGiDXc6Fs0vCUdu+fkhAxyjzOgBj4Ro9PL9A==
X-Received: by 2002:a17:902:112b:: with SMTP id d40mr6541679pla.31.1556890058516;
        Fri, 03 May 2019 06:27:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuNbD4GiMZdw89lUkmS7tobJ67HtiyAQYhgMraONtN5oFUSHEGrJ/Mx9YZKBlY+SWypvL+
X-Received: by 2002:a17:902:112b:: with SMTP id d40mr6541593pla.31.1556890057758;
        Fri, 03 May 2019 06:27:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556890057; cv=none;
        d=google.com; s=arc-20160816;
        b=r7sASZRLCfIYgTVKSQgL7sxd3ReVwYV5fuGV9/W8FRNEf5AbHVv5/7aWUW/sly+Ph8
         9vQi8XMZj2dRwlUC7pywigau+GjjQdi2WkMXp8FqCl/VY96+LribBkyZu8LBvhtW1aCL
         dN/EompTsniKUUOJmmDcKEmQJWcMVj1FV9LNeCkAAnjyiO0QtDEpcKQNqnFDcYaw1jwV
         3gdA0dQwoqVFqS7go4Qo2H1JS0kvs08rrNcYT0Jp4yH/ryPTbFO0/pMUgbz8hq+h1p+q
         qFSyyG5In0ahIDENOQ7DUyt1DaCyZLuAQ8j4HDZQvpJ1c8hQj7Faw7HsMbDOIFduvwGv
         BjYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=mkGg1i+EI0XU//yFAO+gJW+bQDnnQU83x/RNkUevVAw=;
        b=lOSYxu+xJCJkhOKb0BtJV6BPNsc54HXXBVXmOYQudeDiWz07nZH9GjjoNer47utcQV
         iGukyaSvpFHEOIBxieWjm1xkN4ebIpAziMti2OpuoMtypc3K7RVdExF+ROKHOgmvStgP
         lUAHHvhpX1rS15bV5HLQURINAvQ9kdARjRQMFKHAC804QGTtBX3lPTRtBGLb92SJu3KV
         LVCvUG3jPx1avdPfNicF5p/IwIjJ1wZquWxOgBNx0xSEfuIyi8dG+TRc3e3oEPjhhy6A
         xcEa6FqZPW7hMLVfqf2dWdpQUmn9vbc9jbeOLxE3I+2YLaIzTztA1S3qII/KQgXlPTjD
         fmJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=T9s51+W+;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v24si2199807pff.230.2019.05.03.06.27.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 03 May 2019 06:27:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=T9s51+W+;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=mkGg1i+EI0XU//yFAO+gJW+bQDnnQU83x/RNkUevVAw=; b=T9s51+W+nABH6PVAvlfgP+ohw
	RCDyHolxbxOczp+Cg0V5Q3SXBf36YHMOis1fkWWpWSE0zZx6A65FVoDithh+5zNBA/L+/pInK3O58
	PPdp9B6gb5Mj1aHlTOwgYd7feLRBi467iD6vPhfKK/abUZfZCHY1041K3TtWkrj1V0TUQ8aWIVhLI
	+/1YzsyjItpsKuqA6JsKXlZeS7WEi7325sCVTFrE7teQKa5lOodL28eu5Nt6D+miXBGjogCaXg8yc
	VVRuwIZrSBtfheGOujAaXemlnM9xeF/eEeaLHQrjpzSd4fVzD5UcaEhjqq1fDcHkpcop11b8UYehV
	hXvd6JaeQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hMYDu-0006ZD-4h; Fri, 03 May 2019 13:27:34 +0000
Date: Fri, 3 May 2019 06:27:33 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>, jglisse@redhat.com,
	Mike Rapoport <rppt@linux.vnet.ibm.com>, x86@kernel.org,
	linux-efi@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
	intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org
Subject: Re: [PATCH] mm/pgtable: Drop pgtable_t variable from pte_fn_t
 functions
Message-ID: <20190503132733.GA5201@bombadil.infradead.org>
References: <1556803126-26596-1-git-send-email-anshuman.khandual@arm.com>
 <20190502134623.GA18948@bombadil.infradead.org>
 <20190502161457.1c9dbd94@mschwideX1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190502161457.1c9dbd94@mschwideX1>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 02, 2019 at 04:14:57PM +0200, Martin Schwidefsky wrote:
> On Thu, 2 May 2019 06:46:23 -0700
> Matthew Wilcox <willy@infradead.org> wrote:
> 
> > On Thu, May 02, 2019 at 06:48:46PM +0530, Anshuman Khandual wrote:
> > > Drop the pgtable_t variable from all implementation for pte_fn_t as none of
> > > them use it. apply_to_pte_range() should stop computing it as well. Should
> > > help us save some cycles.  
> > 
> > You didn't add Martin Schwidefsky for some reason.  He introduced
> > it originally for s390 for sub-page page tables back in 2008 (commit
> > 2f569afd9c).  I think he should confirm that he no longer needs it.
> 
> With its 2K pte tables s390 can not deal with a (struct page *) as a reference
> to a page table. But if there are no user of the apply_to_page_range() API
> left which actually make use of the token argument we can safely drop it.

Interestingly, I don't think there ever was a user which used that
argument.  Looking at your 2f56 patch, you only converted one function
(presumably there was only one caller of apply_to_page_range() at the
time), and it didn't u se any of the arguments.  Xen was the initial user,
and the two other functions they added also didn't use that argument.

Looking at a quick sample of users added since, none of them appear to
have ever used that argument.  So removing it seems best.

Acked-by: Matthew Wilcox <willy@infradead.org>

