Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A757AC3A59D
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 07:59:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68A0A21726
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 07:59:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HUVknUFG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68A0A21726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 174B76B02DD; Thu, 22 Aug 2019 03:59:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 125676B02DE; Thu, 22 Aug 2019 03:59:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03A9D6B02DF; Thu, 22 Aug 2019 03:59:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0103.hostedemail.com [216.40.44.103])
	by kanga.kvack.org (Postfix) with ESMTP id D5E8F6B02DD
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 03:59:55 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 7D98E180AD7C3
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:59:55 +0000 (UTC)
X-FDA: 75849315150.21.light32_7396d5cd0b21d
X-HE-Tag: light32_7396d5cd0b21d
X-Filterd-Recvd-Size: 2985
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:59:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=+paMvfjrV5Cyt2Na5QthK2etUNCHHInfRHmuAwrcRXg=; b=HUVknUFGmxnPC3xhkKvDw2rmF
	l4o/EMby74fuU8xXgd3F0V1YMzmqwTkZdDtEQ3KiEzcKWZYu9AihjfRGdicwu5/QUW6rowDSQBxLg
	xW4n+usCDfCdVWn0JmbjIiV/h8aG7LOdOJFu89iz+JLc77g5KlrPkEnkJOT41Fd9nvHH7OdF+Tcmt
	AilUUmSBH4BNHa8NZhYkDsUBFMZAbwO/xtx3OCKOqq1GEC2kYxfFT0aLTpk2adq3ZkabfOkc8l62i
	LA1sKd6GPgP58vDupgWvYs0WsUuhaoWkWgpxxFikZ45BotcyZ+d1CSro6QqVCO6Pm+DJ8BMcvFP7i
	b9NHh6Mfg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i0i0a-0000bf-6I; Thu, 22 Aug 2019 07:59:48 +0000
Date: Thu, 22 Aug 2019 00:59:48 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 2/3] xfs: add kmem_alloc_io()
Message-ID: <20190822075948.GA31346@infradead.org>
References: <20190821083820.11725-1-david@fromorbit.com>
 <20190821083820.11725-3-david@fromorbit.com>
 <20190821232440.GB24904@infradead.org>
 <20190822003131.GR1119@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190822003131.GR1119@dread.disaster.area>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 10:31:32AM +1000, Dave Chinner wrote:
> > Btw, I think we should eventually kill off KM_NOFS and just use
> > PF_MEMALLOC_NOFS in XFS, as the interface makes so much more sense.
> > But that's something for the future.
> 
> Yeah, and it's not quite as simple as just using PF_MEMALLOC_NOFS
> at high levels - we'll still need to annotate callers that use KM_NOFS
> to avoid lockdep false positives. i.e. any code that can be called from
> GFP_KERNEL and reclaim context will throw false positives from
> lockdep if we don't annotate tehm correctly....

Oh well.  For now we have the XFS kmem_wrappers to turn that into
GFP_NOFS so we shouldn't be too worried, but I think that is something
we should fix in lockdep to ensure it is generally useful.  I've added
the maintainers and relevant lists to kick off a discussion.


