Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F390C3A5A8
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 19:02:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8E8721670
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 19:02:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="pDxHaccz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8E8721670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58DE36B0003; Wed,  4 Sep 2019 15:02:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 564266B0006; Wed,  4 Sep 2019 15:02:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 456F86B0007; Wed,  4 Sep 2019 15:02:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0205.hostedemail.com [216.40.44.205])
	by kanga.kvack.org (Postfix) with ESMTP id 1EDCB6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 15:02:02 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id B708C52A7
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 19:02:01 +0000 (UTC)
X-FDA: 75898158042.28.plant35_68f6c49e17e11
X-HE-Tag: plant35_68f6c49e17e11
X-Filterd-Recvd-Size: 2820
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 19:02:01 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DE7CD2087E;
	Wed,  4 Sep 2019 19:01:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1567623720;
	bh=A0p265L38NV6UyAt6+h0NKJkV9Yhds5FJHvN1ygxV4c=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=pDxHacczS7aRbBpwyiXA4vrhf5y08lCIaa7YP/dIu1wq26LCRg6bclT5fKTTVLyGH
	 1U3klZixQDuOyfP5k6u7kLvIMKM4+3SRc7wXpKnAnVKk8yB7IRbiJtdR3maDYRkAfA
	 mu7Oteopa+BITB2kX1vIAZjqSCc0R63PbOkQ7VYE=
Date: Wed, 4 Sep 2019 12:01:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: zhong jiang <zhongjiang@huawei.com>, mhocko@kernel.org,
 anshuman.khandual@arm.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Ira Weiny <ira.weiny@intel.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: Unsigned 'nr_pages' always larger than zero
Message-Id: <20190904120159.d4026b573f419838d77e991d@linux-foundation.org>
In-Reply-To: <5505fa16-117e-8890-0f48-38555a61a036@suse.cz>
References: <1567592763-25282-1-git-send-email-zhongjiang@huawei.com>
	<5505fa16-117e-8890-0f48-38555a61a036@suse.cz>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Sep 2019 13:24:58 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 9/4/19 12:26 PM, zhong jiang wrote:
> > With the help of unsigned_lesser_than_zero.cocci. Unsigned 'nr_pages"'
> > compare with zero. And __get_user_pages_locked will return an long value.
> > Hence, Convert the long to compare with zero is feasible.
> 
> It would be nicer if the parameter nr_pages was long again instead of unsigned
> long (note there are two variants of the function, so both should be changed).
> 
> > Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> 
> Fixes: 932f4a630a69 ("mm/gup: replace get_user_pages_longterm() with FOLL_LONGTERM")
> 
> (which changed long to unsigned long)
> 
> AFAICS... stable shouldn't be needed as the only "risk" is that we goto
> check_again even when we fail, which should be harmless.
> 

Really?  If nr_pages gets a value of -EFAULT from the
__get_user_pages_locked() call, check_and_migrate_cma_pages() will go
berzerk?

And does __get_user_pages_locked() correctly handle a -ve errno
returned by __get_user_pages()?  It's hard to see how...


