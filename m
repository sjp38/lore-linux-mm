Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47F5FC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:52:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F34122070D
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:52:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MRHCCiJ+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F34122070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2D516B0003; Fri, 10 May 2019 12:52:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DEED6B0006; Fri, 10 May 2019 12:52:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F56A6B0007; Fri, 10 May 2019 12:52:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 58EB66B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 12:52:15 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e128so4488651pfc.22
        for <linux-mm@kvack.org>; Fri, 10 May 2019 09:52:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=hkMgP0pxOFd4HXfh4zG7QpG6/qI5aXSYBZKtEO3EEOI=;
        b=pNxQLFnwgSEotCmILc+52DaoWOo6dMQK2gL9plRvUtPXT7FjtNmpGSl21tndrB392a
         7xUgNJ4l7+oc88ReLE4fDA3KYEdxpeRnqSG2JTZrFQe+iFi1s+tg85W4ax5QK18gbruY
         uuf6F3ay7XHQvCfMIRBaHkIJQeiZa+wwxkd+qkLwLUJDU13VboSH8vL7YgqYUO2InXip
         RsfHhcC/H1wouWQQdn4ALz2B/fBjZLpD3nxf5IhRsTJure8+8FUMFUlHyc8BQ4MzubW9
         12hNZFHUHA2nRebPMqB0HRhe6FnZpHePZ09TUgyzjcfNyQ58PnC6ih9KF+RaZuctU7Uf
         9tfQ==
X-Gm-Message-State: APjAAAUqbqvR9a4sRFygdO9wo9X9I37VGxBUQvSbjEP280TPta5n0ZH7
	6R7vak1/OG5cRjiwLXya9djSsQEYveNVRz3QHJRuwVVrFb/RTVvdZBMwjTkU+KMpkQx9uES8epV
	ziyQbsppAnElwsNqdlGnOP+gOngML2d9UGBNoXnROML/z/RPDIOWuhEzKSWf6opvUDg==
X-Received: by 2002:a65:6494:: with SMTP id e20mr6597812pgv.117.1557507134933;
        Fri, 10 May 2019 09:52:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwmVV6feC1HwFPve1JW3AdLWq3bX7Yw7EIiKTxLqXJg3SOfeiTpeVnguQwe5eg37fn0zW/S
X-Received: by 2002:a65:6494:: with SMTP id e20mr6597735pgv.117.1557507134276;
        Fri, 10 May 2019 09:52:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557507134; cv=none;
        d=google.com; s=arc-20160816;
        b=hKqo7cg8naxfYKcik8SrspaHT+el9YREiMT03Y2x8F+Hco2CkBDwhTwSW9CYxiJPgL
         VQGDG8Z9hVpCd06C/SNiXgbVgi1Sh36z7h9iYB75hz3KoINOTk3zqiPR8pIBQ/cPA1Sn
         QLb8NzIEmQlnbshPQurO27XNaFtQwlzE80+5/VUi0R/cEO6GXA56PIZLEEOa0jPZAuaK
         8Er2c/UWWbzXBe+xM+5QLVtRUCUhWW6SY2YL+/xoIlCQvTXTiy7KNhuMAAOVQ9/C6wdt
         u9gYTBVusGbO0CS20RZD48pj/Lk+8JdnWlMI3ydJa0qC/XI3HEJz2b+lWTY9dNvoxIXL
         KHjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=hkMgP0pxOFd4HXfh4zG7QpG6/qI5aXSYBZKtEO3EEOI=;
        b=GLmkj+wKiUzTjoKOk9Rq7l6WUbs/X5KBCRtC81/nOUeC5C6XdHFltNV3hsTk7ZJ3y5
         mI58v58vvc/EfBRck9puDMKUabX5m0im8YJgB/psZ2oEqXFZagr/8gshgP7pLRFuNDvm
         w7s4OvN/Jar5lLaZidCGN0NZdpNsIWpGYxB+bpWIYK4IF6P1SKhlG3+eji7gANjrvaje
         njWnWrQXIkZwJfuO6OgQwdbRaS/NruSf29GVvPIMpEZy+2zBY+K5JCfmBvkiqNB21kwx
         Ad7vq6CrTdAdIrVqkoD+PKrWapbe5Bret1NZ50KjO3ywSRt2KxxuMpi6l6tQ5nG8wVVS
         quMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MRHCCiJ+;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q23si8306662pgq.246.2019.05.10.09.52.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 09:52:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MRHCCiJ+;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=hkMgP0pxOFd4HXfh4zG7QpG6/qI5aXSYBZKtEO3EEOI=; b=MRHCCiJ+3KeZif+1OowuNRo8gx
	rw7Pi279ZHHTn8y+BPlMF+KGvPAKwTr37z9Le5nCCU1xz0k7mZTBVhCYs+rrX1T4qSXTySjZOVkgi
	FBkfp8faCE6Yp6LnvgcG3RoGA3/Q4LrApYMwdTfaWfeoBJIh3f9bdUwV4LpCNcqccpSO9e5SzeC55
	bwjPm+PaV0By4jwPQ29iFDXr0OACaYxAJJILFO4Gni3WsTwj68bWAnoSyx3FpWLgXcaFSd6ZirxlU
	0IGUnh+W3pbx1E1b1A5SgRfD666iyufVPJKb++1gBE6nHF68XkZ6DP/SWIcLissANZMhMeybeCplc
	PoVJlybA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP8kh-00045a-F2; Fri, 10 May 2019 16:52:07 +0000
Date: Fri, 10 May 2019 09:52:07 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, hannes@cmpxchg.org,
	mhocko@suse.com, mgorman@techsingularity.net,
	kirill.shutemov@linux.intel.com, hughd@google.com,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: vmscan: correct nr_reclaimed for THP
Message-ID: <20190510165207.GB3162@bombadil.infradead.org>
References: <1557447392-61607-1-git-send-email-yang.shi@linux.alibaba.com>
 <87y33fjbvr.fsf@yhuang-dev.intel.com>
 <20190510163612.GA23417@bombadil.infradead.org>
 <3a919cba-fefe-d78e-313a-8f0d81a4a75d@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3a919cba-fefe-d78e-313a-8f0d81a4a75d@linux.alibaba.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 09:50:04AM -0700, Yang Shi wrote:
> On 5/10/19 9:36 AM, Matthew Wilcox wrote:
> > On Fri, May 10, 2019 at 10:12:40AM +0800, Huang, Ying wrote:
> > > > +		nr_reclaimed += (1 << compound_order(page));
> > > How about to change this to
> > > 
> > >          nr_reclaimed += hpage_nr_pages(page);
> > Please don't.  That embeds the knowledge that we can only swap out either
> > normal pages or THP sized pages.  I'm trying to make the VM capable of
> > supporting arbitrary-order pages, and this would be just one more place
> > to fix.
> > 
> > I'm sympathetic to the "self documenting" argument.  My current tree has
> > a patch in it:
> > 
> >      mm: Introduce compound_nr
> >      Replace 1 << compound_order(page) with compound_nr(page).  Minor
> >      improvements in readability.
> > 
> > It goes along with this patch:
> > 
> >      mm: Introduce page_size()
> > 
> >      It's unnecessarily hard to find out the size of a potentially huge page.
> >      Replace 'PAGE_SIZE << compound_order(page)' with page_size(page).
> 
> So you prefer keeping using  "1 << compound_order" as v1 did? Then you will
> convert all "1 << compound_order" to compound_nr?

Yes.  Please, let's merge v1 and ignore v2.

