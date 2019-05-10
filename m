Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B63C8C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 23:06:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 688382184E
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 23:06:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ST5fCNq3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 688382184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F08E56B0003; Fri, 10 May 2019 19:06:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB96E6B0005; Fri, 10 May 2019 19:06:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA8526B0006; Fri, 10 May 2019 19:06:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9FC2A6B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 19:06:39 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 33so4947107pgv.17
        for <linux-mm@kvack.org>; Fri, 10 May 2019 16:06:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=teDBeReCOPgEIA4YvlNHjGWi0MjwIkQN8utbqMkM4JY=;
        b=PR1IFMCSs4yMjYhvkzW60Rt+7ZSATRtjMYE9AYkZCnT9okWQFh/uT5mHAv4huYXuuw
         cQoC6q2RAYSOi2EBphp50HgjdovjS90xP27tyaeD5EzZ3n1+5bnT8H8yvwxlEbw5yC/0
         jyA+QgNsham9oqy9hzCYJkVumI4A7dCz8k+It0kjG269NSl7ZB6tD69qDCzDVcG+O3ky
         2wqbc0nYvc23BiEVvuZdZmqZOLodlw4epbjWPRwR1yaDexZUdxwtVrArxlznVllv1nkf
         1GBVBIskQBdnbE0+WnFOqJxapyaHBXaenGOL/jWWQbhfI499iL43jR+Czc8Jbrh8RNtj
         X9nA==
X-Gm-Message-State: APjAAAUu+vLQwtB9598XPT3HcNXR9GiBSpzVlJeMn1mNfpaktD0tuS5O
	gn7xEc2cZdv4PrY/sCPFlz56XQRH9UTQuWlwuvanfc8E3YwB1i/PfZQVi6yXnNOIVfCTjrO/OcK
	Ii6Wp7wpt3ixjtFaOwYi3x/Cl6vvCxineahKl3/F0FLDhT71qnhEO7XVyoDWLz5YxGQ==
X-Received: by 2002:a63:5c25:: with SMTP id q37mr17175258pgb.263.1557529599330;
        Fri, 10 May 2019 16:06:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwc8XzDgUMWJNATIKtpsswFWlvYcnyPVzjE2AyM5YLlaKe7miDXx+z+PsrvHLOiGosgpR5/
X-Received: by 2002:a63:5c25:: with SMTP id q37mr17175194pgb.263.1557529598527;
        Fri, 10 May 2019 16:06:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557529598; cv=none;
        d=google.com; s=arc-20160816;
        b=dsOOfPKddMM7iYdfvAHVBxdAiszDEtafnOB0PTuvlcIhZYaMn4pfnLGk1K8ZU39Su/
         1ubVyiokFyROBIqsjDP4lPCFbtNqJemwwHv1AvprnUkBkFJYbBqRjLUiiHGR00zJqhWB
         Oubvrae2xmYixtxdXMJFOSDcArdppsUj67nQgPiOHyr1dXlzrT4MmjQ4FB6jb13eGUPS
         ttrPlhJO2b6JZddpso4gfnk6q0iCShlZQyjNYW59ZCnsbGTMyzrY/DFQG2J1tjfh4mLv
         30uPrvMCsY40Yox4JidRmAnCi667+MeT/3HNQ+scdHTMZt1pU95A+JZTedBW0WKqfzxt
         ofZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=teDBeReCOPgEIA4YvlNHjGWi0MjwIkQN8utbqMkM4JY=;
        b=Rh67rKhg2viu9xATIixYBleOPGTAAXEd3K9A0/FfvP5gqt+KRCBHZvFZtTC98QHQSZ
         YDnEkV7poDNYrC5tNxajCd/MRTwyvLQjo7znvhE2LlyA3j3ZRsnKS6ruaIxGgfTngT6D
         xIU2HFFU/u2HzPGEi/4upwFxWHBi6ufj7nGVzkI+qu5tCbrZZqOmbqJ+K0ph8xbAfC/F
         EkOxk9XibjqygMHJ3NOFUqOckSoYks9kLd3C9ihXHhkQd3lDiJsfRpitzjORMZqqu/K7
         UFyErnV+TP/fZuurCnLf1SybFCcCw6bV2cSuprYOeUnoa8lxc/lXFX8c64Xcv9wX+5Tk
         KUEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ST5fCNq3;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v10si9320955pgt.412.2019.05.10.16.06.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 16:06:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ST5fCNq3;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=teDBeReCOPgEIA4YvlNHjGWi0MjwIkQN8utbqMkM4JY=; b=ST5fCNq3P16ipcDSRBeOWzXml
	7FhiGG3myj/I9/8Od4g2FDJVl9ra/7I3wWkDFs6SeTRoh80jmS4DDdjyxLupc8Bl6jPM5l+/e6a5b
	uLpGRA0jwaOCHY/yAQzIcZJ8WBFx/3PHUFcPCWrHBPGzelKMROkf6g1BseGmVMIJBNINg8LEzDh4e
	+svUFpd86SF1IZxArY1qnaSa3EC/RVFtM8knp2iF2UHLHb1H1RtvjLJV0h8LdpFsDpFkxyrG1/FNI
	NAYuDoCSGtAaSmp55TEUHro31WNrR0UfaKk9Gny1/nkZ0GljaDyN7FpN80UAKr2DP26E7q+QHm/yk
	dEQFe4j6g==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hPEaq-0005m7-7X; Fri, 10 May 2019 23:06:20 +0000
Date: Fri, 10 May 2019 16:06:20 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Ira Weiny <ira.weiny@intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>, hannes@cmpxchg.org,
	mhocko@suse.com, mgorman@techsingularity.net,
	kirill.shutemov@linux.intel.com, hughd@google.com,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: vmscan: correct nr_reclaimed for THP
Message-ID: <20190510230620.GA12158@bombadil.infradead.org>
References: <1557447392-61607-1-git-send-email-yang.shi@linux.alibaba.com>
 <87y33fjbvr.fsf@yhuang-dev.intel.com>
 <20190510163612.GA23417@bombadil.infradead.org>
 <20190510225456.GA13529@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190510225456.GA13529@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 03:54:56PM -0700, Ira Weiny wrote:
> On Fri, May 10, 2019 at 09:36:12AM -0700, Matthew Wilcox wrote:
> > On Fri, May 10, 2019 at 10:12:40AM +0800, Huang, Ying wrote:
> > > > +		nr_reclaimed += (1 << compound_order(page));
> > > 
> > > How about to change this to
> > > 
> > > 
> > >         nr_reclaimed += hpage_nr_pages(page);
> > 
> > Please don't.  That embeds the knowledge that we can only swap out either 
> > normal pages or THP sized pages.  I'm trying to make the VM capable of 
> > supporting arbitrary-order pages, and this would be just one more place
> > to fix.
> > 
> > I'm sympathetic to the "self documenting" argument.  My current tree has
> > a patch in it:
> > 
> >     mm: Introduce compound_nr
> >     
> >     Replace 1 << compound_order(page) with compound_nr(page).  Minor
> >     improvements in readability.
> > 
> > It goes along with this patch:
> > 
> >     mm: Introduce page_size()
> > 
> >     It's unnecessarily hard to find out the size of a potentially huge page.
> >     Replace 'PAGE_SIZE << compound_order(page)' with page_size(page).
> > 
> > Better suggestions on naming gratefully received.  I'm more happy with 
> > page_size() than I am with compound_nr().  page_nr() gives the wrong
> > impression; page_count() isn't great either.
> 
> Stupid question : what does 'nr' stand for?

NumbeR.  It's relatively common argot in the Linux kernel (as you can
see from the earlier example ...

> > >         nr_reclaimed += hpage_nr_pages(page);

willy@bobo:~/kernel/xarray-2$ git grep -w nr mm |wc -l
388
willy@bobo:~/kernel/xarray-2$ git grep -w nr fs |wc -l
1067

