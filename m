Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 604D9C3A5A5
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 06:09:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 226222145D
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 06:09:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 226222145D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B61746B0003; Thu,  5 Sep 2019 02:09:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B11346B0005; Thu,  5 Sep 2019 02:09:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A26476B0006; Thu,  5 Sep 2019 02:09:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0223.hostedemail.com [216.40.44.223])
	by kanga.kvack.org (Postfix) with ESMTP id 7BFF76B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 02:09:36 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 22C90283C
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 06:09:36 +0000 (UTC)
X-FDA: 75899840352.24.rake00_70de5648bdd15
X-HE-Tag: rake00_70de5648bdd15
X-Filterd-Recvd-Size: 2433
Received: from huawei.com (szxga06-in.huawei.com [45.249.212.32])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 06:09:35 +0000 (UTC)
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 04943DFB539C480715D5;
	Thu,  5 Sep 2019 14:09:32 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS401-HUB.china.huawei.com
 (10.3.19.201) with Microsoft SMTP Server id 14.3.439.0; Thu, 5 Sep 2019
 14:09:26 +0800
Message-ID: <5D70A695.60706@huawei.com>
Date: Thu, 5 Sep 2019 14:09:25 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Matthew Wilcox <willy@infradead.org>
CC: <akpm@linux-foundation.org>, <vbabka@suse.cz>, <mhocko@kernel.org>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2] mm: Unsigned 'nr_pages' always larger than zero
References: <1567649871-60594-1-git-send-email-zhongjiang@huawei.com> <20190905031252.GN29434@bombadil.infradead.org>
In-Reply-To: <20190905031252.GN29434@bombadil.infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/9/5 11:12, Matthew Wilcox wrote:
> On Thu, Sep 05, 2019 at 10:17:51AM +0800, zhong jiang wrote:
>> With the help of unsigned_lesser_than_zero.cocci. Unsigned 'nr_pages'
>> compare with zero. And __gup_longterm_locked pass an long local variant
>> 'rc' to check_and_migrate_cma_pages. Hence it is nicer to change the
>> parameter to long to fix the issue.
> I think this patch is right, but I have concerns about this cocci grep.
>
> The code says:
>
>                 if ((nr_pages > 0) && migrate_allow) {
>
> There's nothing wrong with this (... other than the fact that nr_pages might
> happen to be a negative errno).  nr_pages might be 0, and this would be
> exactly the right test for that situation.  I suppose some might argue
> that this should be != 0 instead of > 0, but it depends on the situation
> which one would read better.
>
> So please don't blindly make these changes; you're right this time.
Thanks for your affirmation.  but Andrew come up with anther fix,  using an local long variant
to store the nr_pages.  which one do you prefer ?

Thanks,
zhong jiang


