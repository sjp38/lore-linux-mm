Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1D72C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 11:19:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E15C2084B
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 11:19:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PwT0K4nl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E15C2084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED8A56B000C; Tue,  9 Apr 2019 07:19:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E883F6B000D; Tue,  9 Apr 2019 07:19:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D76936B000E; Tue,  9 Apr 2019 07:19:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F97D6B000C
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 07:19:14 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y10so4153844pll.14
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 04:19:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=E01rP1CzaZ83xn8o+c2fpKU03Lvuczg2ah01j9WWPH4=;
        b=Yfskg8cmdNct6J8Fgo6cUTjCqYj6Q92EIWEHDPqkKhtI+h1u2aQF4GI8ms9EN7qq13
         3frZvLS1oIuIhbW6FGFRR1Dnm2cpjS+pYM9Ke19QAStoUsV2mVJpZBFNg1tgwnSkv63D
         A1iYpFvmgzr6+NH6U9OST54oVBpD/DMQPnqLikwIzbu9+qjy91mG5HspnoIJiwaju17a
         yb+EkeLJHJdZA2/wDIc5hPNFixoDtxP8McOzktLmt8rjilS1ZB+ahlAXxSFBSM2dXKLt
         iIDpoH981JFUoNyuWn/1h/8Hi8/KWyetr+Kr4tqzlpRqhMJtzdP+xbRbSfJ2wLUBH41p
         9eTA==
X-Gm-Message-State: APjAAAUJoOAvrVedBxDLlqB5N6ZqK5v/6T1Kh/W6ecCz3pTEC327t6Z4
	KcT5WbMBk4yEuXPxwxR/ZxEsPzdy/xKMdfncgB1+iFtYMg8CVyAABu5GTSm73UCniG8lDCCRTRg
	N99UKut0aEDX1Qv0gMxUTRJobLzkMXUPcRTdzErx6cZ3f78E6fHMfcUaG+XOdeqwySg==
X-Received: by 2002:a63:4e64:: with SMTP id o36mr34723847pgl.213.1554808754059;
        Tue, 09 Apr 2019 04:19:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTD6k0eJBTX2/MBGNYvb09I71Z3bSv+2g2kIcuwuC2Uf5Dzh7pHYOWWGwAVN2U3gDWuA8q
X-Received: by 2002:a63:4e64:: with SMTP id o36mr34723782pgl.213.1554808753157;
        Tue, 09 Apr 2019 04:19:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554808753; cv=none;
        d=google.com; s=arc-20160816;
        b=bSGieCy2iFq6dxk0mHfNEZM7OoGfcZqkmykbcv3uRSoAuDNTZoi5kGH5By2bCo9eXy
         Nil28a1CPZ8ffXq+kRKlpJVhNQO+BlFwpuJbBVSojge0+SqYvnUORm8YBgeAbD3Sirui
         f5BATy7WKOjtzK6/TYDojDqiaKDsrnRU/CNItgmIdqs7DBdVsN2zSE3HTb93EKzZxA3a
         tb6TBocHpJvcWd3swKaz53LvWjOPPmSi0ZvwMoOw2/xzdiHigPZB6mBgzD3Z6X9H6j68
         ofqmaY+MRU7D86nbJM8nhN1b1DL2aYCWFVQFqoAWjwFExqE+KxD4axzFQcsJX2YYpo8S
         ZlRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=E01rP1CzaZ83xn8o+c2fpKU03Lvuczg2ah01j9WWPH4=;
        b=aBxIzmLljSdWzCwsrPRxIPxEZGsknhcSgor6L5mPiMLqZSBnGFOnp5xe1dybbKF9oL
         zbDfxRjVwoGgTt9mjAZbjhchGhJhsNMkS68zfYDmIqX/2hu5LL9BBHizrwDi9lFRQ1yx
         yH4DFUdK8YLHjiInENt4f/1fjNsWDGhCmhuR+CU2wmcfH8sbNd19NpVCbMEfHDqkERxC
         4I0PFv6NkotURgFobP1vGS4efy4j6vnysJfvefKl2+IXpktWeIgR5Vxwfvsst+EOV3+T
         3j2kk2qoW/p3ul0DnhIiZeOH+YNB8wStjTW1ZRcvZqJya+AQd7mK73Slghi0LYhWMKfr
         7waQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PwT0K4nl;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id i26si29607342pfd.140.2019.04.09.04.19.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 04:19:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) client-ip=198.137.202.133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PwT0K4nl;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=E01rP1CzaZ83xn8o+c2fpKU03Lvuczg2ah01j9WWPH4=; b=PwT0K4nl0C08dBLQN0wy7x7xH
	Wa02Me+d0qh8DbWHZYZE9bp7fomcBEi3facq6HUAVgZW29g43+x9/jjvwrxASsZi1LkDPVdV1kkXA
	spYD2wmPJo0vIB/Lq/lWuw7DQWRI5vzxORwGjcELcZ4GRHk3STryCC5fzqC0VG3if87CfNyPyc39e
	0vYX7KALh6ly40A3kGUuEVPiNkqM5wW2TCE9DWNE+umNaUPsTWtDGtdRlYlVtsv8IcFqqubvqUcbo
	tsMRXp3md5QlcqVwmqPGTLK/r8GUeM0c+uxIjwwoR1tljkTYjr6O9kqK7i/YUnC0jmvANRPve5QkG
	LVQuBTjaQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hDomQ-0000gi-0S; Tue, 09 Apr 2019 11:19:06 +0000
Date: Tue, 9 Apr 2019 04:19:05 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Huang Shijie <sjhuang@iluvatar.ai>
Cc: akpm@linux-foundation.org, william.kucharski@oracle.com,
	ira.weiny@intel.com, palmer@sifive.com, axboe@kernel.dk,
	keescook@chromium.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] mm/gup.c: fix the wrong comments
Message-ID: <20190409111905.GY22763@bombadil.infradead.org>
References: <20190408023746.16916-1-sjhuang@iluvatar.ai>
 <20190408141313.GU22763@bombadil.infradead.org>
 <20190409010832.GA28081@hsj-Precision-5520>
 <20190409024929.GW22763@bombadil.infradead.org>
 <20190409030417.GA3324@hsj-Precision-5520>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190409030417.GA3324@hsj-Precision-5520>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 09, 2019 at 11:04:18AM +0800, Huang Shijie wrote:
> On Mon, Apr 08, 2019 at 07:49:29PM -0700, Matthew Wilcox wrote:
> > On Tue, Apr 09, 2019 at 09:08:33AM +0800, Huang Shijie wrote:
> > > On Mon, Apr 08, 2019 at 07:13:13AM -0700, Matthew Wilcox wrote:
> > > > On Mon, Apr 08, 2019 at 10:37:45AM +0800, Huang Shijie wrote:
> > > > > The root cause is that sg_alloc_table_from_pages() requires the
> > > > > page order to keep the same as it used in the user space, but
> > > > > get_user_pages_fast() will mess it up.
> > > > 
> > > > I don't understand how get_user_pages_fast() can return the pages in a
> > > > different order in the array from the order they appear in userspace.
> > > > Can you explain?
> > > Please see the code in gup.c:
> > > 
> > > 	int get_user_pages_fast(unsigned long start, int nr_pages,
> > > 				unsigned int gup_flags, struct page **pages)
> > > 	{
> > > 		.......
> > > 		if (gup_fast_permitted(start, nr_pages)) {
> > > 			local_irq_disable();
> > > 			gup_pgd_range(addr, end, gup_flags, pages, &nr);               // The @pages array maybe filled at the first time.
> > 
> > Right ... but if it's not filled entirely, it will be filled part-way,
> > and then we stop.
> > 
> > > 			local_irq_enable();
> > > 			ret = nr;
> > > 		}
> > > 		.......
> > > 		if (nr < nr_pages) {
> > > 			/* Try to get the remaining pages with get_user_pages */
> > > 			start += nr << PAGE_SHIFT;
> > > 			pages += nr;                                                  // The @pages is moved forward.
> > 
> > Yes, to the point where gup_pgd_range() stopped.
> > 
> > > 			if (gup_flags & FOLL_LONGTERM) {
> > > 				down_read(&current->mm->mmap_sem);
> > > 				ret = __gup_longterm_locked(current, current->mm,      // The @pages maybe filled at the second time
> > 
> > Right.
> > 
> > > 				/*
> > > 				 * retain FAULT_FOLL_ALLOW_RETRY optimization if
> > > 				 * possible
> > > 				 */
> > > 				ret = get_user_pages_unlocked(start, nr_pages - nr,    // The @pages maybe filled at the second time.
> > > 							      pages, gup_flags);
> > 
> > Yes.  But they'll be in the same order.
> > 
> > > BTW, I do not know why we mess up the page order. It maybe used in some special case.
> > 
> > I'm not discounting the possibility that you've found a bug.
> > But documenting that a bug exists is not the solution; the solution is
> > fixing the bug.
> I do not think it is a bug :)
> 
> If we use the get_user_pages_unlocked(), DMA is okay, such as:
>                      ....
> 		     get_user_pages_unlocked()
> 		     sg_alloc_table_from_pages()
> 	             .....
> 
> I think the comment is not accurate enough. So just add more comments, and tell the driver
> users how to use the GUPs.

gup_fast() and gup_unlocked() should return the pages in the same order.
If they do not, then it is a bug.

