Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_2
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 517B6C3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:07:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20EE722CEA
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:07:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20EE722CEA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B24CC6B0003; Wed,  4 Sep 2019 10:07:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AAE436B0006; Wed,  4 Sep 2019 10:07:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99CCF6B0007; Wed,  4 Sep 2019 10:07:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0170.hostedemail.com [216.40.44.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7236F6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 10:07:46 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1D58D180AD804
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:07:46 +0000 (UTC)
X-FDA: 75897416532.30.59F2920
Received: from filter.hostedemail.com (10.5.16.251.rfc1918.com [10.5.16.251])
	by smtpin30.hostedemail.com (Postfix) with ESMTP id 78F00180B3CBC
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:06:15 +0000 (UTC)
X-HE-Tag: rail59_8db3ccfed2334
X-Filterd-Recvd-Size: 3727
Received: from mailgw01.mediatek.com (unknown [210.61.82.183])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:06:13 +0000 (UTC)
X-UUID: f362c8a6c104411aa10ef7ebe1987d5b-20190904
X-UUID: f362c8a6c104411aa10ef7ebe1987d5b-20190904
Received: from mtkexhb02.mediatek.inc [(172.21.101.103)] by mailgw01.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0809 with TLS)
	with ESMTP id 2107079500; Wed, 04 Sep 2019 22:06:06 +0800
Received: from mtkcas09.mediatek.inc (172.21.101.178) by
 mtkmbs07n1.mediatek.inc (172.21.101.16) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Wed, 4 Sep 2019 22:06:05 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas09.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Wed, 4 Sep 2019 22:06:04 +0800
Message-ID: <1567605965.32522.14.camel@mtksdccf07>
Subject: Re: [PATCH 1/2] mm/kasan: dump alloc/free stack for page allocator
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Vlastimil Babka <vbabka@suse.cz>
CC: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko
	<glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Matthias Brugger
	<matthias.bgg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Martin
 Schwidefsky" <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>,
	<kasan-dev@googlegroups.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-mediatek@lists.infradead.org>, <wsd_upstream@mediatek.com>
Date: Wed, 4 Sep 2019 22:06:05 +0800
In-Reply-To: <401064ae-279d-bef3-a8d5-0fe155d0886d@suse.cz>
References: <20190904065133.20268-1-walter-zh.wu@mediatek.com>
	 <401064ae-279d-bef3-a8d5-0fe155d0886d@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-09-04 at 14:49 +0200, Vlastimil Babka wrote:
> On 9/4/19 8:51 AM, Walter Wu wrote:
> > This patch is KASAN report adds the alloc/free stacks for page allocator
> > in order to help programmer to see memory corruption caused by page.
> > 
> > By default, KASAN doesn't record alloc/free stack for page allocator.
> > It is difficult to fix up page use-after-free issue.
> > 
> > This feature depends on page owner to record the last stack of pages.
> > It is very helpful for solving the page use-after-free or out-of-bound.
> > 
> > KASAN report will show the last stack of page, it may be:
> > a) If page is in-use state, then it prints alloc stack.
> >    It is useful to fix up page out-of-bound issue.
> 
> I expect this will conflict both in syntax and semantics with my series [1] that
> adds the freeing stack to page_owner when used together with debug_pagealloc,
> and it's now in mmotm. Glad others see the need as well :) Perhaps you could
> review the series, see if it fulfils your usecase (AFAICS the series should be a
> superset, by storing both stacks at once), and perhaps either make KASAN enable
> debug_pagealloc, or turn KASAN into an alternative enabler of the functionality
> there?
> 
> Thanks, Vlastimil
> 
> [1] https://lore.kernel.org/linux-mm/20190820131828.22684-1-vbabka@suse.cz/t/#u
> 
Thanks your information.
We focus on the smartphone, so it doesn't enable
CONFIG_TRANSPARENT_HUGEPAGE, Is it invalid for our usecase?
And It looks like something is different, because we only need last
stack of page, so it can decrease memory overhead.
I will try to enable debug_pagealloc(with your patch) and KASAN, then we
see the result.

Thanks.
Walter 


