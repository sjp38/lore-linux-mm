Return-Path: <SRS0=KlKP=WU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 848EFC3A59E
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 15:28:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F950206DD
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 15:28:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TJwImQZi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F950206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 632936B04DF; Sat, 24 Aug 2019 11:28:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BC436B04E5; Sat, 24 Aug 2019 11:28:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4ABA06B04E6; Sat, 24 Aug 2019 11:28:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0039.hostedemail.com [216.40.44.39])
	by kanga.kvack.org (Postfix) with ESMTP id 226BA6B04DF
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 11:28:21 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 96175181AC9B6
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 15:28:20 +0000 (UTC)
X-FDA: 75857702760.22.tray25_48ca5740f3608
X-HE-Tag: tray25_48ca5740f3608
X-Filterd-Recvd-Size: 2280
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 15:28:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=r+fW1Mxx/WIOu0q7eOdTyS41mAFDLJVl/S3haneWLp8=; b=TJwImQZiE0XYYd1CswYHKW5n6
	jG39tv4RXZ9E9B3XED+e0S6SToGeMhKbPpp6dwYr5CxjxKxdgflwAfCVnFUwl/OeP0meDvFrlf75S
	2o4ykmjqVh19ogfzTo/37YmlZ/g1Kwjf5arpB8hQiwMQGKQGQeP3VX0RdWSaK87+husw8zGa0+fZf
	zlaWbbtggtuhd+5J4JY5k0MZHMXqGuVQlSGoqQ011ARiZHhj6NHN+5232GgXeRNNyHcbuikZkOJSs
	sr71cua8POM0V9JPilHsDUDUMSdvCPrzlzrENXlVlCHwKgo74NgIO4PIFO8KcM97OLvPRuOqrrT9C
	yWXLB2w8A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i1Xxa-0002mp-NM; Sat, 24 Aug 2019 15:28:10 +0000
Date: Sat, 24 Aug 2019 08:28:10 -0700
From: Matthew Wilcox <willy@infradead.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-fsdevel@vger.kernel.org, hch@lst.de,
	linux-xfs@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 2/5] mm: Add file_offset_of_ helpers
Message-ID: <20190824152810.GA28002@bombadil.infradead.org>
References: <20190821003039.12555-3-willy@infradead.org>
 <201908241913.Slt7yyks%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201908241913.Slt7yyks%lkp@intel.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 24, 2019 at 07:48:24PM +0800, kbuild test robot wrote:
> Hi Matthew,
> 
> Thank you for the patch! Perhaps something to improve:
> 
> [auto build test WARNING on linus/master]
> [cannot apply to v5.3-rc5 next-20190823]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

It depends on various patches which are in -next, although I didn't
generate them against -next.



