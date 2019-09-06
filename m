Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BE99C00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 13:31:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13C3B20650
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 13:31:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="V47IwCs/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13C3B20650
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FC976B0007; Fri,  6 Sep 2019 09:31:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9ACAC6B0008; Fri,  6 Sep 2019 09:31:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 874536B000A; Fri,  6 Sep 2019 09:31:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0172.hostedemail.com [216.40.44.172])
	by kanga.kvack.org (Postfix) with ESMTP id 692BE6B0007
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 09:31:17 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 0C132180AD7C3
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:31:17 +0000 (UTC)
X-FDA: 75904582194.20.page40_62758f3bcd22f
X-HE-Tag: page40_62758f3bcd22f
X-Filterd-Recvd-Size: 2642
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:31:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=1I/BDeipPTsBBKFqmhtdSKTL8wmnK5I8ff1DW4dGwsk=; b=V47IwCs/6Zdz87+2Y+fx3VoxW
	NQNn7HC9fks9UENezH02Z7WWQogRGy0L4HNH5TsGknGf5MAigLI45z5qEcnoNWBOJhlUfFXcaL7qZ
	qq4htdq3dGM2/XNENTNC7N10Bj3TGH3mq2rpu3sBHrFhNZuQ0k79p4H/SIDAICIXzLWANsKy6+kvt
	ULbylV3e/dh4C2TDIAxMW1/UTmjOPRTXpku4blD+jMU1dpm3hKF5bnfOm1EYMboNbUXe9MlZDMcgn
	2u3XflNiLfXK4W3ZD0e4fmKdK/vr004hhakL8WoyW9FK13sgw3oFB9g0iJD5oHAPXCS6RIrH04g3m
	nT/jysphQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i6EKZ-0008Dk-EH; Fri, 06 Sep 2019 13:31:15 +0000
Date: Fri, 6 Sep 2019 06:31:15 -0700
From: Matthew Wilcox <willy@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	Song Liu <songliubraving@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: Re: [PATCH 2/3] mm: Allow large pages to be added to the page cache
Message-ID: <20190906133115.GV29434@bombadil.infradead.org>
References: <20190905182348.5319-1-willy@infradead.org>
 <20190905182348.5319-3-willy@infradead.org>
 <20190906120944.gm6lncxmkkz6kgjx@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190906120944.gm6lncxmkkz6kgjx@box>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 06, 2019 at 03:09:44PM +0300, Kirill A. Shutemov wrote:
> On Thu, Sep 05, 2019 at 11:23:47AM -0700, Matthew Wilcox wrote:
> > +next:
> > +		xas_store(&xas, page);
> > +		if (++i < nr) {
> > +			xas_next(&xas);
> > +			goto next;
> >  		}
> 
> Can we have a proper loop here instead of goto?
> 
> 		do {
> 			xas_store(&xas, page);
> 			/* Do not move xas ouside the range */
> 			if (++i != nr)
> 				xas_next(&xas);
> 		} while (i < nr);

We could.  I wanted to keep it as close to the shmem.c code as possible,
and this code is scheduled to go away once we're using a single large
entry in the xarray instead of N consecutive entries.


