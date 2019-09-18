Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B576C4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 23:49:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35AF221897
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 23:49:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RTaqfzBp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35AF221897
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D89B96B0311; Wed, 18 Sep 2019 19:49:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D144B6B0312; Wed, 18 Sep 2019 19:49:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C29B66B0313; Wed, 18 Sep 2019 19:49:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0128.hostedemail.com [216.40.44.128])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0876B0311
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 19:49:29 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1C88E181AC9B4
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 23:49:29 +0000 (UTC)
X-FDA: 75949685658.04.club06_52c4ce2060937
X-HE-Tag: club06_52c4ce2060937
X-Filterd-Recvd-Size: 2931
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 23:49:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=9B/jgHS7PD/DOi2AjcR19b+jtGzxXg3UqwFXdzQJuJ8=; b=RTaqfzBph/Z2r/rLphAOle23G
	lBBoCZ650sphFB2nq53YzVYS6suvjOIXb/E7nQWwuYJMk9lZOvQPEPUrX3xrLXHY4ZACCUtEiEhHw
	l9vJpF5r066Ojn5AZ5o3Ze5fsnGR6HCjgqCGSVYNchu+tlw8GH+OLnFdgdvfSdJC/0qT1TGI7pIwq
	MxUzTt/PfDpu8QqsHzMZWhueJ0mYoRq4Xy0s20ok1MPmn93vOjrtZh85pgn/84dFRM5BGhfNMCjfR
	eVlXrt51wfwnVUNlK7DEsKGgozND1UN1+dhy6KjDenYue5RC7iWLowhkRonYKJhR98jMVqmI3i5kL
	qAGVf4obA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92.2 #3 (Red Hat Linux))
	id 1iAjhM-00084W-UO; Wed, 18 Sep 2019 23:49:24 +0000
Date: Wed, 18 Sep 2019 16:49:24 -0700
From: Matthew Wilcox <willy@infradead.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-fsdevel@vger.kernel.org, hch@lst.de, linux-xfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2 2/5] mm: Add file_offset_of_ helpers
Message-ID: <20190918234924.GE9880@bombadil.infradead.org>
References: <20190821003039.12555-1-willy@infradead.org>
 <20190821003039.12555-3-willy@infradead.org>
 <20190918211755.GC2229799@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190918211755.GC2229799@magnolia>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 18, 2019 at 02:17:55PM -0700, Darrick J. Wong wrote:
> On Tue, Aug 20, 2019 at 05:30:36PM -0700, Matthew Wilcox wrote:
> > From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> > 
> > The page_offset function is badly named for people reading the functions
> > which call it.  The natural meaning of a function with this name would
> > be 'offset within a page', not 'page offset in bytes within a file'.
> > Dave Chinner suggests file_offset_of_page() as a replacement function
> > name and I'm also adding file_offset_of_next_page() as a helper for the
> > large page work.  Also add kernel-doc for these functions so they show
> > up in the kernel API book.
> > 
> > page_offset() is retained as a compatibility define for now.
> 
> No SOB?
> 
> Looks fine to me, and I appreciate the much less confusing name.  I was
> hoping for a page_offset conversion for fs/iomap/ (and not a treewide
> change because yuck), but I guess that can be done if and when this
> lands.

Sure, I'll do that once everything else has landed.

