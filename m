Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DDA4C43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 22:12:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BB82206DF
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 22:12:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DwJAHupY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BB82206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A3156B0003; Thu,  5 Sep 2019 18:12:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 753BD6B0005; Thu,  5 Sep 2019 18:12:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 669DD6B0007; Thu,  5 Sep 2019 18:12:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0155.hostedemail.com [216.40.44.155])
	by kanga.kvack.org (Postfix) with ESMTP id 44CB96B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:12:37 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E99C9824CA38
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 22:12:36 +0000 (UTC)
X-FDA: 75902267112.11.able29_50d2fc800a234
X-HE-Tag: able29_50d2fc800a234
X-Filterd-Recvd-Size: 2412
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 22:12:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=hXxhd2FAe3cwB9R+ZW9hYGuNtaZo0DXOOGKLsZp7Vlg=; b=DwJAHupYCe0KBYPUY++xKXNtX
	KNFsVks8Q6faF0UinUX03iscnrEEQfBD9LwGf673IRScjuZIxM6EDPHpRjrDMW9W5Z/zdRbcI1iVj
	DmTiqJzddle/jwr2qPw+ONbSQ6MLp5ifm7oB/9fXTYpDoLz2Qp8vusbM+isLkyJOGaWl7flVTfq6u
	IIjPZa4Cq1Urw3dQY/kyB10TNLBthJdFR6BP/PEM9r3PKugJixBQnGhO08HXGTny2tArqIAFbrQnm
	zqt4d9Ud4ymRK2EVtu9MdO32qQum/vfbHzRJmM9CDxSHUGyTpivuPH266I6BS4s5wTxQQ725Wsn+X
	HBIDTWMtA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i5zzU-0004ms-F5; Thu, 05 Sep 2019 22:12:32 +0000
Date: Thu, 5 Sep 2019 15:12:32 -0700
From: Matthew Wilcox <willy@infradead.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	Kirill Shutemov <kirill@shutemov.name>,
	Song Liu <songliubraving@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: Re: [PATCH 3/3] mm: Allow find_get_page to be used for large pages
Message-ID: <20190905221232.GU29434@bombadil.infradead.org>
References: <20190905182348.5319-4-willy@infradead.org>
 <201909060632.Sn0F0fP6%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201909060632.Sn0F0fP6%lkp@intel.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 06, 2019 at 06:04:05AM +0800, kbuild test robot wrote:
> Hi Matthew,
> 
> Thank you for the patch! Yet something to improve:
> 
> [auto build test ERROR on linus/master]
> [cannot apply to v5.3-rc7 next-20190904]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

It looks like you're not applying these to the -mm tree?  I thought that
was included in -next.



