Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BD64C41514
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 07:59:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51CA722CF7
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 07:59:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51CA722CF7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 010EB6B0003; Mon,  2 Sep 2019 03:59:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F02EA6B0006; Mon,  2 Sep 2019 03:59:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E189F6B0007; Mon,  2 Sep 2019 03:59:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0002.hostedemail.com [216.40.44.2])
	by kanga.kvack.org (Postfix) with ESMTP id C04C06B0003
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 03:59:04 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 68DFD824CA2D
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 07:59:04 +0000 (UTC)
X-FDA: 75889229808.30.goat17_14f7840aeef08
X-HE-Tag: goat17_14f7840aeef08
X-Filterd-Recvd-Size: 1924
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 07:59:03 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 48EE8227A8A; Mon,  2 Sep 2019 09:59:00 +0200 (CEST)
Date: Mon, 2 Sep 2019 09:58:59 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Guenter Roeck <linux@roeck-us.net>, Christoph Hellwig <hch@lst.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas =?iso-8859-1?Q?Hellstr=F6m?= <thomas@shipmail.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Steven Price <steven.price@arm.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Thomas Hellstrom <thellstrom@vmware.com>
Subject: Re: [PATCH 2/3] pagewalk: separate function pointers from iterator
 data
Message-ID: <20190902075859.GA29137@lst.de>
References: <20190828141955.22210-1-hch@lst.de> <20190828141955.22210-3-hch@lst.de> <20190901184530.GA18656@roeck-us.net> <20190901193601.GB5208@mellanox.com> <b26ac5ae-a90c-7db5-a26c-3ace2f1530c7@roeck-us.net> <20190902055156.GA24116@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190902055156.GA24116@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 02, 2019 at 05:51:58AM +0000, Jason Gunthorpe wrote:
> On Sun, Sep 01, 2019 at 01:35:16PM -0700, Guenter Roeck wrote:
> > > I belive the macros above are missing brackets.. Can you confirm the
> > > below takes care of things? I'll add a patch if so
> > > 
> > 
> > Good catch. Yes, that fixes the build problem.
> 
> I added this to the hmm tree to fix it:

This looks good.  Although I still haven't figure out how this is
related to the pagewalk changes to start with..

