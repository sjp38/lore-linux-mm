Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82E37C3A59E
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 06:43:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 515C82173B
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 06:43:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 515C82173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3ACF6B000C; Sat, 17 Aug 2019 02:43:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEBDB6B000D; Sat, 17 Aug 2019 02:43:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D01566B000E; Sat, 17 Aug 2019 02:43:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0063.hostedemail.com [216.40.44.63])
	by kanga.kvack.org (Postfix) with ESMTP id B05756B000C
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:43:06 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 5ABC6180ABF4B
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 06:43:06 +0000 (UTC)
X-FDA: 75830977572.06.rain90_1b0e15275ca0c
X-HE-Tag: rain90_1b0e15275ca0c
X-Filterd-Recvd-Size: 2112
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 06:43:05 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id ADCC568B05; Sat, 17 Aug 2019 08:43:01 +0200 (CEST)
Date: Sat, 17 Aug 2019 08:43:01 +0200
From: Christoph Hellwig <hch@lst.de>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@mellanox.com>,
	Christoph Hellwig <hch@infradead.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Thomas =?iso-8859-1?Q?Hellstr=F6m?= <thomas@shipmail.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Steven Price <steven.price@arm.com>, Linux-MM <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	Minchan Kim <minchan@kernel.org>
Subject: Re: cleanup the walk_page_range interface
Message-ID: <20190817064301.GA18544@lst.de>
References: <20190808154240.9384-1-hch@lst.de> <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com> <20190816062751.GA16169@infradead.org> <20190816115735.GB5412@mellanox.com> <20190816123258.GA22140@lst.de> <20190816140623.4e3a5f04ea1c08925ac4581f@linux-foundation.org> <20190817164124.683d67ff@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190817164124.683d67ff@canb.auug.org.au>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 17, 2019 at 04:41:24PM +1000, Stephen Rothwell wrote:
> I certainly prefer that method of API change :-)
> (see the current "keys: Replace uid/gid/perm permissions checking with
> an ACL" in linux-next and the (currently) three merge fixup patches I
> am carrying.  Its not bad when people provide the fixes, but I am no
> expert in most areas of the kernel ...)

It would mean pretty much duplicating all the code.  And then never
finish the migration because new users of the old interfaces keep
popping up.  Compared to that I'd much much prefer either Linus
taking it now or a branch.

