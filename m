Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08FF3C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:33:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D742820644
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:33:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D742820644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8452B6B0003; Fri, 16 Aug 2019 08:33:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F4C26B0005; Fri, 16 Aug 2019 08:33:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70B5A6B000A; Fri, 16 Aug 2019 08:33:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0206.hostedemail.com [216.40.44.206])
	by kanga.kvack.org (Postfix) with ESMTP id 503B76B0003
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:33:03 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id EC1D98410
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:33:02 +0000 (UTC)
X-FDA: 75828230604.16.bed65_71de2c68dc423
X-HE-Tag: bed65_71de2c68dc423
X-Filterd-Recvd-Size: 1760
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:33:02 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 87FE068B05; Fri, 16 Aug 2019 14:32:58 +0200 (CEST)
Date: Fri, 16 Aug 2019 14:32:58 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas =?iso-8859-1?Q?Hellstr=F6m?= <thomas@shipmail.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Steven Price <steven.price@arm.com>, Linux-MM <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	Minchan Kim <minchan@kernel.org>
Subject: Re: cleanup the walk_page_range interface
Message-ID: <20190816123258.GA22140@lst.de>
References: <20190808154240.9384-1-hch@lst.de> <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com> <20190816062751.GA16169@infradead.org> <20190816115735.GB5412@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816115735.GB5412@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 11:57:40AM +0000, Jason Gunthorpe wrote:
> Are there conflicts with trees other than hmm?
> 
> We can put it on a topic branch and merge to hmm to resolve. If hmm
> has problems then send the topic on its own?

I see two new walk_page_range user in linux-next related to MADV_COLD
support (which probably really should use walk_range_vma), and then
there is the series from Steven, which hasn't been merged yet.

