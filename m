Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3378C282C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 21:34:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE27E2080A
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 21:34:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fYYyMijD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE27E2080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BE348E0069; Thu,  7 Feb 2019 16:34:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46E318E0002; Thu,  7 Feb 2019 16:34:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35E0B8E0069; Thu,  7 Feb 2019 16:34:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E7D628E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 16:34:04 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id m3so893214pfj.14
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 13:34:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=HG08h4CmN+ciP15Ueo5cb7ygRxxsUAXIB93CDy90Co8=;
        b=sl1YMH8E5JX0tRT7HdbH7d0IgrgvyqkO2/eKcQQJT3Q5u23o0eEDutPZHRBU/U6AQl
         lmybdP/Q+029o/Xu3kluHMC35S0ZIygFBbBmZSMCbDaPm6lhyuu61ifL+VOuUKFRFF+H
         47C+OEeJCeFFXIBFFzhO1AOtH4xDoGf/m3ZupYimYs8ckDQIpT4NXtd0cd+d2Y/WSvPR
         Lt8i8NrnVxReGEfX8tUiybA/oFf+53GSErfY1AfuIHRq7qKHu23cxbQmfee3NvrKcfXg
         CaqlSl6r6sd7RBzk+MFxootcLbm21eXoUsNknw6QS7crrZzo52PvLjKWal9lXxEv4Ztw
         RrNQ==
X-Gm-Message-State: AHQUAubai1MSMk8v5FKq9RWn+8pWglht6kdVG5IDuD/ZvnR0wTx/PTWS
	hEZll0dWbI3sY8PVguDWASIkx5iLbyEXPCyOM7fEeNCAXY+JSsFA5fCQbQwgKZ9DPWAxIcNpcWa
	JxzjQqpAarsCZnhDIG0QQZmD287uQ87fyOSinp/wrdufb0gvabjfdzjvNmngrxJPvBA==
X-Received: by 2002:a17:902:7608:: with SMTP id k8mr13195985pll.245.1549575244503;
        Thu, 07 Feb 2019 13:34:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia423lGEL69DNe1z9+OS/VZ7UDskgUt8Olnv4mGSbUXb82cu/fGNJcff8fCOrRg9Zxy2OBT
X-Received: by 2002:a17:902:7608:: with SMTP id k8mr13195930pll.245.1549575243878;
        Thu, 07 Feb 2019 13:34:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549575243; cv=none;
        d=google.com; s=arc-20160816;
        b=UQv7rl5glY+7WAyudOQMey8tlRmmL0aKATLffW1qunW6QfCq3eZdPKidg8u/UJwtpw
         BgfqlhuOIiMVCzZgHnQn4BewR4krWR3RVNRoP/f5ThXVSZzmJWSNpC/K+RyDLjG/yr4g
         4zo7AUfn34vThccjhFqQBZcd/4rUlQcOu7taeZFUsV/W4SbonmYKeA7Y8kEZjFbu2JcY
         I4WKH3YIQusHbQhlEwTYb1QdgSAihWyKsAC2ldVLM2fSct8GBC9tj2mFpqYhTB7yWvOe
         G33MJLHSIiZXNsn/Lf5PG6hvql3gHdV6UZb2wcd6kpXppoJ4dHae1Ir/0TKFt6+buH37
         S2qA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=HG08h4CmN+ciP15Ueo5cb7ygRxxsUAXIB93CDy90Co8=;
        b=IfbHVJ1ilf84xeMaY4ojcnTKn+ZmLDerg4Clm5bshxTd03HfoCy4qNzd/Adk3yAZkX
         yqYroOtJhq7Wc1S3D5XUR0bdQSgfE/jOKmo5Ll+Fo8eswtS2n3kZbTrHo7/Cp6oRVmfg
         QN2eVHSfEUoEC74/U9ayVZeaAjigZVx30YIckzdHsSvrlllX2Xc9CL2FvFwR11NPrftN
         tHb5i/2fA5rpYZ6udhZnpHE4iK/NXgGtzgmyR9oaOWqnTUivaSux+e8botRAZd+DGmKz
         Kbq36U1npsJAK1xTvL14HA3ERBY3eaRwRnHaNYSVI4o3uTOKQ+m47h11TBeqwhnQBA0C
         f9UA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fYYyMijD;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g18si85394pgg.522.2019.02.07.13.34.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Feb 2019 13:34:03 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fYYyMijD;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=HG08h4CmN+ciP15Ueo5cb7ygRxxsUAXIB93CDy90Co8=; b=fYYyMijD4PfDANyUpdYdCZ8Fs
	xs3HOHrHkVF/mvPORPIGrhDkfF9kKyKSNB6iSti79NsolaETOQ5NAl3oHwWcC1kUcfprUH+MlSWtM
	PX5hfDmGNCnVh71sLL0glMteCIYyOTAk5m0EFuGtXXdUkQTYuX9M6M9bzrnMtxUvzTvjgiX1GWjvN
	3+Ux8j7ezVnOquhfvEtd1uqiF2R+JD10+geAUz1rKQEbGnzG3XNdF0O8CMQhzkgy6jKeTHAU+dTTd
	ag65a59UVQbkgVjBjeGISZkHJ7MnLZfeaCa+5HIhUUuMk/sgQ+EluRVF5b+mRawqZ/pmMIqaShjGP
	8biSq85hg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1grrJ2-0001RM-NI; Thu, 07 Feb 2019 21:34:00 +0000
Date: Thu, 7 Feb 2019 13:34:00 -0800
From: Matthew Wilcox <willy@infradead.org>
To: David Miller <davem@davemloft.net>
Cc: ilias.apalodimas@linaro.org, brouer@redhat.com, tariqt@mellanox.com,
	toke@redhat.com, netdev@vger.kernel.org,
	mgorman@techsingularity.net, linux-mm@kvack.org
Subject: Re: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Message-ID: <20190207213400.GA21860@bombadil.infradead.org>
References: <1549550196-25581-1-git-send-email-ilias.apalodimas@linaro.org>
 <20190207150745.GW21860@bombadil.infradead.org>
 <20190207152034.GA3295@apalos>
 <20190207.132519.1698007650891404763.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190207.132519.1698007650891404763.davem@davemloft.net>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 01:25:19PM -0800, David Miller wrote:
> From: Ilias Apalodimas <ilias.apalodimas@linaro.org>
> Date: Thu, 7 Feb 2019 17:20:34 +0200
> 
> > Well updating struct page is the final goal, hence the comment. I am mostly
> > looking for opinions here since we are trying to store dma addresses which are
> > irrelevant to pages. Having dma_addr_t definitions in mm-related headers is a
> > bit controversial isn't it ? If we can add that, then yes the code would look
> > better
> 
> I fundamentally disagree.
> 
> One of the core operations performed on a page is mapping it so that a device
> and use it.
> 
> Why have ancillary data structure support for this all over the place, rather
> than in the common spot which is the page.
> 
> A page really is not just a 'mm' structure, it is a system structure.

+1

The fundamental point of computing is to do I/O.

