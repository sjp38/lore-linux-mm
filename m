Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01AA3C43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:15:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7F93206BA
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:15:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="o9E+hzoJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7F93206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1500C6B0003; Thu,  5 Sep 2019 14:15:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 101756B0005; Thu,  5 Sep 2019 14:15:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 015FB6B0007; Thu,  5 Sep 2019 14:15:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0126.hostedemail.com [216.40.44.126])
	by kanga.kvack.org (Postfix) with ESMTP id D05E76B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:15:57 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 7623D181AC9AE
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:15:57 +0000 (UTC)
X-FDA: 75901670754.20.mass84_33f1daf96525b
X-HE-Tag: mass84_33f1daf96525b
X-Filterd-Recvd-Size: 3922
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:15:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=KNZWU7yGq0onbgTNSsWFJ/xolOca5Um/wuC1clkXtHE=; b=o9E+hzoJiqmONz9X78dmwqG2Z
	wqUoYM7XM02UU5HuIOkab8bAtjkRAAYjt70EYcezyr6MEm0o88Bhq5mYdYa9lrJIhRW3dTQLzIevo
	YJPCel9l+VogSAgLp2k0pxM1AKM0QGaH/z2tY0qUwBNu43fCqB4a40wH778fpAV9990/ciC/8zbbf
	Izhab0yOCSxjz2sHj15WfEES242ZoQf6P2AwXlKGozufbK39dQKPjYP2NAUDdE0b2K6oNsB7PS1rk
	HyJ5NOg8qhCoB4QvNVsDRzJGW40v+zG84pI0JVwCw0z2U2wkGxyjhgBF686EJIGdckFjNTxVAdyB4
	ox9rNwbig==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i5wIV-00081i-Oe; Thu, 05 Sep 2019 18:15:55 +0000
Date: Thu, 5 Sep 2019 11:15:55 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Dominique Martinet <asmadeus@codewreck.org>
Cc: linux-mm@kvack.org
Subject: Re: How to use huge pages in drivers?
Message-ID: <20190905181555.GQ29434@bombadil.infradead.org>
References: <20190903182627.GA6079@nautica>
 <20190903184230.GJ29434@bombadil.infradead.org>
 <20190903212815.GA7518@nautica>
 <20190904170056.GA9825@nautica>
 <20190904175032.GL29434@bombadil.infradead.org>
 <20190905154400.GA30549@nautica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190905154400.GA30549@nautica>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 05, 2019 at 05:44:00PM +0200, Dominique Martinet wrote:
> > You shouldn't be calling vmf_insert_pfn_pmd() from a regular ->fault
> > handler, as by then the fault handler has already inserted a PMD.
> > The ->huge_fault handler is the place to call it from.
> > 
> > You may need to force PMD-alignment for your call to mmap().
> 
> I was missing setting the VM_HUGE_FAULT vm_flags2 bit in the vma - the
> huge_fault handler is now called, and I no longer have the pre-existing
> pmd problem; that's a much better solution than manually fiddling with
> flags :)
> 
> Question though - is it ok to insert small pages if the huge_fault
> handler is called with PE_SIZE_PMD ?
> (I think the pte insertion will automatically create the pmd, but would
> be good to confirm)

No, you need to return VM_FAULT_FALLBACK, at which point the generic code
will create a PMD for you and then call your ->fault handler which can
insert PTEs.

It works the same way from PUDs to PMDs by the way, in case you ever
have a 1GB mapping ;-)

> Now I've got this I'm back to where I stood with my kludge though,
> programs work until they exit, and the zap_huge_pmd() function tries to
> withdraw the pagetable from some magic field that was never set in my
> case... I realize this is old code no longer upstream, but my new
> workaround for this (looking at the zap_huge_pmd function) was to
> pretend my file is dax.
> Now that I've set it as dax I think it actually makes sense as in
> "there's memory here that points to something linux no longer manages
> directly, just let it be" and we might benefit from the other exceptions
> dax have, I'll need to look at what this implies in more details...

I think that should be fine, but I don't really know RHEL 7.3 all that
well ;-)

> > Hope these pointers are slightly more useful than a rubber duck ;-)
> 
> Much appreciated, thank you for taking the time! :)

No problem ... these APIs are relatively new and not necessarily all
that intuitive.

