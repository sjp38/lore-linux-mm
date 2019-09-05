Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4511C3A5AA
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 03:13:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99C202053B
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 03:13:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="cHAm9zd5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99C202053B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FA026B0003; Wed,  4 Sep 2019 23:13:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 183DB6B0005; Wed,  4 Sep 2019 23:13:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 023BE6B0006; Wed,  4 Sep 2019 23:13:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0110.hostedemail.com [216.40.44.110])
	by kanga.kvack.org (Postfix) with ESMTP id CFBD46B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 23:13:06 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4F0282C22
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 03:13:06 +0000 (UTC)
X-FDA: 75899395572.22.blow21_1a9b53c9c8e08
X-HE-Tag: blow21_1a9b53c9c8e08
X-Filterd-Recvd-Size: 2716
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 03:13:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=WEjrnZDEQ7TEULc6lJk+4RAyKQtPI4nwd9rxNIbJ2jo=; b=cHAm9zd5r9eSCAYO8QFECjnW4
	0Dk5zbKC31VWKl/JUYWtv00YeI7QfLQiGXbxIlOorWOUanHJ2hMa99ADeWrROCZg9JNGf4ksACh6z
	zRF696B1RJbXdL8oQ4SrmxJLHvYh7hr5eMXUrNrBCErM17z5ixySKuhuBYvLvKP4OesVV8HxaURg/
	39Asm8TljlGNtzOvKofXbjApxD89NCGNtbNSOXb/H0XiE1KXes2DaxJu7DqLVaUYIIJGFNGXomtE4
	7iVN3beLW0y90LSzkhJPK9u4wuiEZ4d5jo6DycTHi6fvygzFTpvnXz+k0OwKvkt6Zozn17mu/LxUM
	F18Z+LMjA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i5iCa-0004wA-Mu; Thu, 05 Sep 2019 03:12:52 +0000
Date: Wed, 4 Sep 2019 20:12:52 -0700
From: Matthew Wilcox <willy@infradead.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm: Unsigned 'nr_pages' always larger than zero
Message-ID: <20190905031252.GN29434@bombadil.infradead.org>
References: <1567649871-60594-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1567649871-60594-1-git-send-email-zhongjiang@huawei.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 05, 2019 at 10:17:51AM +0800, zhong jiang wrote:
> With the help of unsigned_lesser_than_zero.cocci. Unsigned 'nr_pages'
> compare with zero. And __gup_longterm_locked pass an long local variant
> 'rc' to check_and_migrate_cma_pages. Hence it is nicer to change the
> parameter to long to fix the issue.

I think this patch is right, but I have concerns about this cocci grep.

The code says:

                if ((nr_pages > 0) && migrate_allow) {

There's nothing wrong with this (... other than the fact that nr_pages might
happen to be a negative errno).  nr_pages might be 0, and this would be
exactly the right test for that situation.  I suppose some might argue
that this should be != 0 instead of > 0, but it depends on the situation
which one would read better.

So please don't blindly make these changes; you're right this time.

