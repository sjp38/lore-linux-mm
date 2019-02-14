Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D978C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:12:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE03C21B1C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:12:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZJoXraRw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE03C21B1C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AE048E0003; Thu, 14 Feb 2019 17:12:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8349B8E0001; Thu, 14 Feb 2019 17:12:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D63B8E0003; Thu, 14 Feb 2019 17:12:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 289B78E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 17:12:00 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id b24so5308988pls.11
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 14:12:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Gwc+mvIl4HoO2YfH2m0A8g4VcbExcOq+aBb16LSf1EI=;
        b=qXtZrZZXUPTqoybWQUdsIwfYvKw58fk4ylD0f0M2rolvlzGgJBi39tNu6Bp4uYfRFD
         ZXqqAySUEPlnosX1WthljmE6OpE0KSn0YDQPPcWg4M+pDJUV5Cmli3z9q4/qh58Q0Ex/
         dsi6rtbW6yekFMcmUhw4qz9C8b+SKacy405Dvu7DMuY9tLCzFFKOfz1OJl14x50Jq2qT
         oMqSab8t7wmUzRSS4w6Hpk8ajzkHhq6exjjfe3fdaFNVHcyrGkgNdQA6rRnYE3ar9VFR
         1pvkFsixEy6ZWkM3yUaXfAJZo1lH4fILNi3WRLCsMlfY0V7JJBzvp4bjkQGjoFo36sG9
         gG2Q==
X-Gm-Message-State: AHQUAua6GYBF4JdmQ/sclzTmvtUXBU6TNZmmjlzZXCXqaFYWSm7eSQU7
	oM1cahKUKCvitVeg4sOpaiwRfr8W7SDnOG7aScVzAzs7XQI7x5JPlU+0UhsLcxSEO4YIOZpfGWr
	pLoMZUlEc49dQlEcDZKFM89mrASZgQTAvu0vTPIxW+trVwq3h8k2LRZDBAeFlmOXcmw==
X-Received: by 2002:a62:3811:: with SMTP id f17mr6541169pfa.206.1550182319853;
        Thu, 14 Feb 2019 14:11:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZuS7Sga/rpxxGvvbjtoeNqWpcQLgJay+5L0QJXDyKI4FhRE/13PJT4oU0DtbrmPbFVQz8M
X-Received: by 2002:a62:3811:: with SMTP id f17mr6541123pfa.206.1550182319229;
        Thu, 14 Feb 2019 14:11:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550182319; cv=none;
        d=google.com; s=arc-20160816;
        b=nR51Xq0kY3tgxH/7nATxTGhA3/apRRnaNxYF0O6RdQuTXV2jCUkMVuWd96XB7Hs5yw
         YprZQYsniycDcdgigSFlFpqs2Jw/ezdpJ3rYf+6ULscdym/7O/mmTJnYKQJQtu2OtlYj
         EmA9B47R2nHhyIw/18cYv8RBkuOaReV1DtR4AzcjmUJ8pIPzy86XeJcST4xsfeRm1jKV
         7u5RkMSzuIfAqnraKDrvBpE2SjLVg5Oa7C8gfxNCOokf4OwxC+RtLhkp9V8LYbJTVwVM
         YA24JgLou63deBeJNDeIfu9M3HphSEeCcXBQqbfFjiCPiGmokdQHGoezAFxDLXFVeJUS
         a4dQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Gwc+mvIl4HoO2YfH2m0A8g4VcbExcOq+aBb16LSf1EI=;
        b=RZywHoPS76m5RBqRhfYRWQtavuQFij8gRR/0fVRvlt3nWUU83H1kW1eNzLvk98HKDo
         kBfqfjaA6zHZVP/8Kx+MwzMpTHrPve8syXtVIj9wLsyf97F2S4m1fUPY0N2PJ3aoC2xM
         EY0gOL+FoNfHHrw43D/t5E26G37RCE2oMnqA7koegHuvo5B97Y+K9m2TaWOzQhKrjLAt
         MUX6yddUNMBAS3isBMo5eWfMN5nnYlUhXN55c1eKQ0NRkOnvFYSvSDV0min3ixeooSUP
         wGpSMUHVLRhovmc3nMzkSEfl+WYkyygkCo6CLwaO+uJ7M8hpqNtCoTyV1hM3wQl6zVUA
         fKwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZJoXraRw;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 34si3414770pgt.455.2019.02.14.14.11.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 14:11:59 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZJoXraRw;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Gwc+mvIl4HoO2YfH2m0A8g4VcbExcOq+aBb16LSf1EI=; b=ZJoXraRwEzPwCjFopYp0D/SBf
	oExrdMzVb4bcoedsPJXTMRiM0f6llqjnv/ND3gdcr+NN16Gq1xGdvVTqEgNNZX38lB+ajiti5MA5t
	QoqGD5j8TSkMmRlf164otrER2pPPxdHs7/xFdtYUKvWe1CM2uv2056tV38vrfj980Q8nYSb4qeZPD
	dF/qOaxvuArkL9sJ76rWgnG0MEcIhoYJk5GtmpFDkCWtXadhb69achm2/Zaps8K9G7VAoZf41Fdk1
	x8bAHEI2bXJ9uISExFkUX+h1zUPiovdWqDjpf2mzLfIBkzHpWLKB8hsFRfWmPNqnMb2owjs0KHqog
	z1ps54Vxg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1guPEc-0006Mt-7X; Thu, 14 Feb 2019 22:11:58 +0000
Date: Thu, 14 Feb 2019 14:11:58 -0800
From: Matthew Wilcox <willy@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v2] page cache: Store only head pages in i_pages
Message-ID: <20190214221158.GF12668@bombadil.infradead.org>
References: <20190212183454.26062-1-willy@infradead.org>
 <20190214133004.js7s42igiqc5pgwf@kshutemo-mobl1>
 <20190214211757.GE12668@bombadil.infradead.org>
 <20190214220810.cs2ecomtrqc6m2ap@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214220810.cs2ecomtrqc6m2ap@kshutemo-mobl1>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 01:08:10AM +0300, Kirill A. Shutemov wrote:
> On Thu, Feb 14, 2019 at 01:17:57PM -0800, Matthew Wilcox wrote:
> > On Thu, Feb 14, 2019 at 04:30:04PM +0300, Kirill A. Shutemov wrote:
> > >  - migrate_page_move_mapping() has to be converted too.
> > 
> > I think that's as simple as:
> > 
> > +++ b/mm/migrate.c
> > @@ -465,7 +465,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
> >  
> >                 for (i = 1; i < HPAGE_PMD_NR; i++) {
> >                         xas_next(&xas);
> > -                       xas_store(&xas, newpage + i);
> > +                       xas_store(&xas, newpage);
> >                 }
> >         }
> >  
> > 
> > or do you see something else I missed?
> 
> Looks right to me.
> 
> BTW, maybe some add syntax sugar from XArray side?
> 
> Replace the loop and xas_store() before it with:
> 
> 		xas_fill(&xas, newpage, 1UL << compound_order(newpage));
> 
> or something similar?

If we were keeping this code longterm, then yes, something like that
would be great.  I'm hoping this code is a mere stepping stone towards
using multi-slot entries for the page cache.

