Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15DF7C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 06:20:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1E692173E
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 06:20:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1E692173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E39F6B0008; Wed, 28 Aug 2019 02:20:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5926C6B000C; Wed, 28 Aug 2019 02:20:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A9966B000D; Wed, 28 Aug 2019 02:20:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0175.hostedemail.com [216.40.44.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2872D6B0008
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 02:20:13 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id BA8BF824CA2F
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 06:20:12 +0000 (UTC)
X-FDA: 75870836664.14.apple66_1ee16a35c0e58
X-HE-Tag: apple66_1ee16a35c0e58
X-Filterd-Recvd-Size: 1809
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 06:20:12 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 144CB68AFE; Wed, 28 Aug 2019 08:20:08 +0200 (CEST)
Date: Wed, 28 Aug 2019 08:20:07 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Thomas =?iso-8859-1?Q?Hellstr=F6m?= <thomas@shipmail.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Steven Price <steven.price@arm.com>, Linux-MM <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Subject: Re: cleanup the walk_page_range interface
Message-ID: <20190828062007.GA21823@lst.de>
References: <20190808154240.9384-1-hch@lst.de> <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com> <20190816062751.GA16169@infradead.org> <20190823134308.GH12847@mellanox.com> <20190824222654.GA28766@infradead.org> <20190827013408.GC31766@mellanox.com> <20190827163431.65a284b295004d1ed258fbd5@linux-foundation.org> <20190827233619.GB28814@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190827233619.GB28814@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 27, 2019 at 11:36:26PM +0000, Jason Gunthorpe wrote:
> Okay, I'll get it on a branch and merge it toward hmm.git tomorrow

I was planning to resend it with the rebase, especially as the build
bot picked a build error in task_mmu.c where we were missing a stub
for an unusual configuration.  I wish I'd remember which one that was..

