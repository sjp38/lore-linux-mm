Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3CBBC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 20:20:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 768EE2175B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 20:20:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ah3y4ju0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 768EE2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9A9C6B0005; Wed, 24 Apr 2019 16:20:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D49506B0006; Wed, 24 Apr 2019 16:20:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5FB36B0007; Wed, 24 Apr 2019 16:20:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC656B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 16:20:09 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a8so12715077pgq.22
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 13:20:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=gtC/CUPlFtAMyxjH1wQBFTK5CfdQnQD/owV+EtKziJE=;
        b=HPnzh+EtK2nfAiToeIsPHSGuPwexn3dkZQx0yZ2h8Iysz4B4o7hSVsyy1VJXbtKqai
         8YoT0X3RcV3mpH3L1O7VrIKGU26ZOk/FcVRNjsQwzamLHOfECUXxhoXyS3nUbJ5CD6sr
         q9e+a3gG7fTIfp+URqtsbddgJ/hVHKBdxPuwUtct1+fT5ONc+bYsrnhhl0fRYzl+vzwz
         5XfcESYWXasCIVP9yRbyRk/GVC9XHnfbhc8ZoxPNeHugHG918M2Osx9e1HFAzH6gjH2+
         Y+vEsxEsspPWJMbEgyLLHbF797RQWtfEYQw09H1U53UPaG8/y24PBapvzGPw8Hh8H4dq
         TG2A==
X-Gm-Message-State: APjAAAU3PGggYXWid4V9iR/RmXAfrRqvPXyUvA5dFVu66aZDm+l5AVG5
	a+bDSTAuWYPPzpuOnSkzrlSYcBfmqBaFGa8kbiyacWfeisrJDFA826ngoM1uSdiSeV6GamnPpNM
	ttCb3Bpc43lKIAVk4mbzqWQVJrJBBUOVpZ8jtvi1mNn6SZDgymDm2/d+qMjx9C9BO8w==
X-Received: by 2002:aa7:9f49:: with SMTP id h9mr10389966pfr.173.1556137208911;
        Wed, 24 Apr 2019 13:20:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5h9qhezZfOh7BPQcFbj0lUegQOJQljlh7k2pekXMwzIHLstDq+WsGtBDjcBQ23t/fvRmX
X-Received: by 2002:aa7:9f49:: with SMTP id h9mr10389901pfr.173.1556137208031;
        Wed, 24 Apr 2019 13:20:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556137208; cv=none;
        d=google.com; s=arc-20160816;
        b=v8Jcbwxc9ItcAaAEXt3nFxI2BSXvXiAQnxqHifZsQ1d89Je7lTR6cHqlL5KmO1u3Ni
         MkyxolfJPmRmrcgwHO7012b3uAIjDjkrDJSwXku/3s80RScGLxEiQWN9WRJ3T/JPr/pm
         +BHHRZKM5COX6WQWqxKrM9KKLmIyR/OkF6aV/kH+pFjxrWMEbWBXcgiLftj85jsHJL5a
         WAmSUP0izcQzPEfphDcr14bLg6cVKtk2TobIndDskpRi7nQ2uoW6DfBz2zUxhtgs5cmV
         EYwVATA31hggRg2cgm3dfzuHzbAGHCCFyESlUJrqs9SARv7iGbSbFhGCTcj/tsLFoeOZ
         wpYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gtC/CUPlFtAMyxjH1wQBFTK5CfdQnQD/owV+EtKziJE=;
        b=hRYBaR29Z0Q+BRCWt9pD7dUnhaT/wd1RtnSsq2UJQ25ZH0YwhhtX3jPintTeL3rXGN
         i6baWSXdJnJM7pxN35rqoXDk/5ihwcOWhnLS2ziDvV9G3tDBpRTFw8q9sD41GWx0YLR+
         +26kNHNGOewqVvbFMRDV55NoWwb6TWaQ1wcI7BIKXzJ7+Xeo3wL4RL+tO4GEL2AXrt80
         rUQD8V98u/IqLMSyEc3Nyye1zAz3xwEo5pyxpRpKA/nz3nRivCrPrfqqVmhKwjsA1Fa5
         vMwXEdpli7witTqg72L2o1/p3XZpc9FxES30NtWQyAquaJ2vGm3uuOfQz7/8KPMbyGA+
         XcbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ah3y4ju0;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c25si21043345pfr.94.2019.04.24.13.20.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 13:20:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ah3y4ju0;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=gtC/CUPlFtAMyxjH1wQBFTK5CfdQnQD/owV+EtKziJE=; b=ah3y4ju0TB4PyH0mfIs0dPXWG
	L7DveKuRwVDmOxpNe3CLWQaTEc5D9U3dJe7BbNiRTTVHOkZCOwEUf1m3dVuFgbaIUr8+cwB5at7fU
	/XyJ8iCoynTcQvBt2W6+Hv6I0f9vPFbZMoq2nqUlc/rSGBS++Kv4E5NKI//DnfjBX8Fw1aY8nZSlL
	bVxd3oUpsw+bjk2PD3GDIOecAtwn5BdZhsvZOV4MIVml6rj+V25+ACOn4C3tL3jnkn6t1hVM22Gu2
	ulVlcynDWatW6rCpxM4bv/v3GecYz55R5Jk1Yv7iFgCvWySyaDZ+hvV781lEWUBbDxmZtvFAEkwot
	+0FeunrEQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJONC-0007u8-Vc; Wed, 24 Apr 2019 20:20:06 +0000
Date: Wed, 24 Apr 2019 13:20:06 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Matthew Garrett <mjg59@google.com>
Cc: linux-mm@kvack.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm: Allow userland to request that the kernel clear
 memory on release
Message-ID: <20190424202006.GH19031@bombadil.infradead.org>
References: <20190424191440.170422-1-matthewgarrett@google.com>
 <20190424192812.GG19031@bombadil.infradead.org>
 <CACdnJutj4K1kQj7yXcCNVWM_hmrUwMfZ-JBi=FHkBvYFfbJNZA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACdnJutj4K1kQj7yXcCNVWM_hmrUwMfZ-JBi=FHkBvYFfbJNZA@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 12:33:11PM -0700, Matthew Garrett wrote:
> On Wed, Apr 24, 2019 at 12:28 PM Matthew Wilcox <willy@infradead.org> wrote:
> > But you can't have a new PageFlag.  Can you instead zero the memory in
> > unmap_single_vma() where we call uprobe_munmap() and untrack_pfn() today?
> 
> Is there any way the page could be referenced by something other than
> a VMA at this point? If so we probably don't want to zero it here, but
> we do want to zero it when the page is finally released (which is why
> I went with a page flag)

It could be the target/source of direct I/O, or userspace could have
registered it with an RDMA device, or ...

It depends on the semantics you want.  There's no legacy code to
worry about here.  I was seeing this as the equivalent of an atexit()
handler; userspace is saying "When this page is unmapped, zero it".
So it doesn't matter that somebody else might be able to reference it --
userspace could have zeroed it themselves.

