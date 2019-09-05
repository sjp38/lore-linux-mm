Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 799CEC00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 19:02:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43AE120CC7
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 19:02:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="U5GYyvEK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43AE120CC7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D89016B0003; Thu,  5 Sep 2019 15:02:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3AAA6B0005; Thu,  5 Sep 2019 15:02:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C511E6B0007; Thu,  5 Sep 2019 15:02:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0110.hostedemail.com [216.40.44.110])
	by kanga.kvack.org (Postfix) with ESMTP id A386E6B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 15:02:41 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 4ADD8181AC9B4
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 19:02:41 +0000 (UTC)
X-FDA: 75901788522.28.crook34_17616ca126344
X-HE-Tag: crook34_17616ca126344
X-Filterd-Recvd-Size: 4399
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 19:02:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=7bfMom3kvI9piHWLFD7o7TyhCUjgttUXe8jaXRejLR8=; b=U5GYyvEK7x+uCm9f4YTJH8HpN
	pG3IMkxK89E6n+y0fFaj91iBPfUVIelVCRFvVhXK72M3IHVRi9o6B61XXKT+wV/i75wzWHbnAS/NY
	J0ajDZ/1mTik6rqlMEk8uK4ufWZIQ/7/GxrHurQylWosywbJJJETsmesuSlLCTJXRc5tmEpAoVxs6
	gF2NeZhikWBN8t1vEi1PIOM47gxoNtw3rda4xiSYteNFepeArY6eUxOvTLhBfxxxQimmKRPsmAoxN
	+ajG8Z0iAVCo6deWkoQX3e/3ALxVP9d3jd8XbdokQUE74ysudSk6eBQLiAoJ2kERzseelD8xzPEID
	dgTxrTeoA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i5x1i-0000MN-7n; Thu, 05 Sep 2019 19:02:38 +0000
Date: Thu, 5 Sep 2019 12:02:38 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Song Liu <songliubraving@fb.com>
Cc: Linux MM <linux-mm@kvack.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	Kirill Shutemov <kirill@shutemov.name>,
	William Kucharski <william.kucharski@oracle.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: Re: [PATCH 1/3] mm: Add __page_cache_alloc_order
Message-ID: <20190905190238.GT29434@bombadil.infradead.org>
References: <20190905182348.5319-1-willy@infradead.org>
 <20190905182348.5319-2-willy@infradead.org>
 <75104154-A1A4-4FE3-920C-0069E1B5848D@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <75104154-A1A4-4FE3-920C-0069E1B5848D@fb.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 05, 2019 at 06:58:53PM +0000, Song Liu wrote:
> > On Sep 5, 2019, at 11:23 AM, Matthew Wilcox <willy@infradead.org> wrote:
> > This new function allows page cache pages to be allocated that are
> > larger than an order-0 page.
> > 
> > Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
> > ---
> > include/linux/pagemap.h | 14 +++++++++++---
> > mm/filemap.c            | 11 +++++++----
> > 2 files changed, 18 insertions(+), 7 deletions(-)
> > 
> > diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> > index 103205494ea0..d2147215d415 100644
> > --- a/include/linux/pagemap.h
> > +++ b/include/linux/pagemap.h
> > @@ -208,14 +208,22 @@ static inline int page_cache_add_speculative(struct page *page, int count)
> > }
> > 
> > #ifdef CONFIG_NUMA
> > -extern struct page *__page_cache_alloc(gfp_t gfp);
> > +extern struct page *__page_cache_alloc_order(gfp_t gfp, unsigned int order);
> 
> I guess we need __page_cache_alloc(gfp_t gfp) here for CONFIG_NUMA. 

... no?  The __page_cache_alloc() below is outside the ifdef/else/endif, so
it's the same for both NUMA and non-NUMA.

> > #else
> > -static inline struct page *__page_cache_alloc(gfp_t gfp)
> > +static inline
> > +struct page *__page_cache_alloc_order(gfp_t gfp, unsigned int order)
> > {
> > -	return alloc_pages(gfp, 0);
> > +	if (order > 0)
> > +		gfp |= __GFP_COMP;
> > +	return alloc_pages(gfp, order);
> > }
> > #endif
> > 
> > +static inline struct page *__page_cache_alloc(gfp_t gfp)
> > +{
> > +	return __page_cache_alloc_order(gfp, 0);
> 
> Maybe "return alloc_pages(gfp, 0);" here to avoid checking "order > 0"?

For non-NUMA cases, the __page_cache_alloc_order() will be inlined into
__page_cache_alloc() and the copiler will eliminate the test.  Or you
need a better compiler ;-)

> > -struct page *__page_cache_alloc(gfp_t gfp)
> > +struct page *__page_cache_alloc_order(gfp_t gfp, unsigned int order)
> > {
> > 	int n;
> > 	struct page *page;
> > 
> > +	if (order > 0)
> > +		gfp |= __GFP_COMP;
> > +
> 
> I think it will be good to have separate __page_cache_alloc() for order 0, 
> so that we avoid checking "order > 0", but that may require too much 
> duplication. So I am on the fence for this one. 

We're about to dive into the page allocator ... two extra instructions
here aren't going to be noticable.

