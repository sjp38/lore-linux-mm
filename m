Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0536BC4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 23:48:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7CF421897
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 23:48:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="rp5ONWHR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7CF421897
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6378F6B030F; Wed, 18 Sep 2019 19:48:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E8756B0310; Wed, 18 Sep 2019 19:48:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 525A66B0311; Wed, 18 Sep 2019 19:48:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0248.hostedemail.com [216.40.44.248])
	by kanga.kvack.org (Postfix) with ESMTP id 32FFC6B030F
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 19:48:43 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D51B4180AD806
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 23:48:42 +0000 (UTC)
X-FDA: 75949683684.27.waste48_4c0a2e072cb4c
X-HE-Tag: waste48_4c0a2e072cb4c
X-Filterd-Recvd-Size: 2755
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 23:48:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=c/M6xmbjhA5kdZWFA1C98tnb2ENEAojyudEyYzGg0Jk=; b=rp5ONWHRQI3PtnhNOgVuIzbZp
	euFJ5EGOoMuY2lvGJU2OscwO2sDRQwbBC6t2+r2287NuXvZkU8Te9J3JogkP6qDLWAiYMLbuekp7+
	TctU1H1qORa00nVptiF7wnWrX6QeVaFFiwI4oi8npc54JoDkVVtol5PG6Z79Uc7041CM8f4FJP35x
	7yHNulGa+6wRbBXlM1rv116+i8ahT96bi8cAIKWq+lrtCaIu+Af0OvArFiu4q9bXSCzoxV7YecIVc
	vBgVGmll1xlZhLUH2nTQQhQSv83ydkXpMFWxg3IykFPnDb+X0+fyZXX7FhxXrnYvL3jeAEmHaLvw4
	fXzeHN1fA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92.2 #3 (Red Hat Linux))
	id 1iAjga-00082Q-A3; Wed, 18 Sep 2019 23:48:36 +0000
Date: Wed, 18 Sep 2019 16:48:36 -0700
From: Matthew Wilcox <willy@infradead.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-fsdevel@vger.kernel.org, hch@lst.de, linux-xfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2 1/5] fs: Introduce i_blocks_per_page
Message-ID: <20190918234836.GD9880@bombadil.infradead.org>
References: <20190821003039.12555-1-willy@infradead.org>
 <20190821003039.12555-2-willy@infradead.org>
 <20190918211439.GB2229799@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190918211439.GB2229799@magnolia>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 18, 2019 at 02:14:39PM -0700, Darrick J. Wong wrote:
> On Tue, Aug 20, 2019 at 05:30:35PM -0700, Matthew Wilcox wrote:
> > From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> > 
> > This helper is useful for both large pages in the page cache and for
> > supporting block size larger than page size.  Convert some example
> > users (we have a few different ways of writing this idiom).
> > 
> > Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
> 
> Seems pretty straightforward, modulo whatever's going on with the kbuild
> robot complaint (is there something wrong, or is it just that obnoxious
> header check thing?)

It doesn't apply patches on top of the -mm tree for some reason.  So
it has no idea about the page_size() macro that's sitting in -mm at the
moment.

> Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

Thanks.

