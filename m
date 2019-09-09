Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76112C433EF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 01:13:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30DB220854
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 01:13:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JGHcyTVk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30DB220854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C51F06B0005; Sun,  8 Sep 2019 21:13:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C01FD6B0006; Sun,  8 Sep 2019 21:13:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1E886B0007; Sun,  8 Sep 2019 21:13:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0105.hostedemail.com [216.40.44.105])
	by kanga.kvack.org (Postfix) with ESMTP id 8A57B6B0005
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 21:13:00 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 3F149824CA38
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 01:13:00 +0000 (UTC)
X-FDA: 75913608120.12.unit18_545c122dcf04d
X-HE-Tag: unit18_545c122dcf04d
X-Filterd-Recvd-Size: 3110
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 01:12:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=qL5AmPwJsgMB2JQa1hapcmg4XfNq+0CQ3w+mAIP5SQ4=; b=JGHcyTVkIbErQE5YeNw3F48V+
	vHU70nXAbJ6WAm8c7SXaQRt6sqrxtDXoIupBqSnVX4ZNeKRDqkjwSOtvip9w8oh+3tLysO8/Ax4Aj
	RGd1LqHtVDSO+v5hIFnFZzB7Hi7p6Q/XAohiFNucEUKEMLpEFJOjNBNRCTeC0leUptEWLJKyiEdVG
	URXHSsrkMzaMtpxOizm5qQTmqqxrqDt3a+vsp9B4XoFeX75LcMCFKZKlsyqbAjdW++qV5szqkzDz4
	RJqeuXPgejQNib+WU2/YjnzeECb+c5O22Y9zVaJDXhgIpV0iP8qFqASTdMr+LJmVxPkEUZmwTEFGq
	XE1FyQ0dg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i78Ef-0000xz-Kp; Mon, 09 Sep 2019 01:12:53 +0000
Date: Sun, 8 Sep 2019 18:12:53 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Rong Chen <rong.a.chen@intel.com>
Cc: kbuild test robot <lkp@intel.com>, Song Liu <songliubraving@fb.com>,
	Johannes Weiner <jweiner@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	linux-mm@kvack.org, kbuild-all@01.org,
	linux-fsdevel@vger.kernel.org,
	Kirill Shutemov <kirill@shutemov.name>
Subject: Re: [kbuild-all] [PATCH 3/3] mm: Allow find_get_page to be used for
 large pages
Message-ID: <20190909011253.GC29434@bombadil.infradead.org>
References: <20190905182348.5319-4-willy@infradead.org>
 <201909060632.Sn0F0fP6%lkp@intel.com>
 <20190905221232.GU29434@bombadil.infradead.org>
 <4b8c3a4d-5a16-6214-eb34-e7a5b36aeb71@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4b8c3a4d-5a16-6214-eb34-e7a5b36aeb71@intel.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 09, 2019 at 08:42:03AM +0800, Rong Chen wrote:
> 
> 
> On 9/6/19 6:12 AM, Matthew Wilcox wrote:
> > On Fri, Sep 06, 2019 at 06:04:05AM +0800, kbuild test robot wrote:
> > > Hi Matthew,
> > > 
> > > Thank you for the patch! Yet something to improve:
> > > 
> > > [auto build test ERROR on linus/master]
> > > [cannot apply to v5.3-rc7 next-20190904]
> > > [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> > It looks like you're not applying these to the -mm tree?  I thought that
> > was included in -next.
> 
> Hi,
> 
> Sorry for the inconvenience, we'll look into it. and 0day-CI introduced
> '--base' option to record base tree info in format-patch.
> could you kindly add it to help robot to base on the right tree? please see
> https://stackoverflow.com/a/37406982

There isn't a stable git base tree to work from with mmotm:

https://www.ozlabs.org/~akpm/mmotm/mmotm-readme.txt

