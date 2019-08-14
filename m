Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AE08C0650F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 07:39:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0252D20843
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 07:39:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0252D20843
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A5B86B0007; Wed, 14 Aug 2019 03:39:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 72FEF6B0008; Wed, 14 Aug 2019 03:39:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F7BA6B000A; Wed, 14 Aug 2019 03:39:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0212.hostedemail.com [216.40.44.212])
	by kanga.kvack.org (Postfix) with ESMTP id 37C206B0007
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 03:39:00 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E3F6D181AC9AE
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:38:59 +0000 (UTC)
X-FDA: 75820231998.13.talk00_3168871c0df31
X-HE-Tag: talk00_3168871c0df31
X-Filterd-Recvd-Size: 2339
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:38:59 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 17B9F68B20; Wed, 14 Aug 2019 09:38:55 +0200 (CEST)
Date: Wed, 14 Aug 2019 09:38:54 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@mellanox.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 04/15] mm: remove the pgmap field from struct
 hmm_vma_walk
Message-ID: <20190814073854.GA27249@lst.de>
References: <20190806160554.14046-1-hch@lst.de> <20190806160554.14046-5-hch@lst.de> <20190807174548.GJ1571@mellanox.com> <CAPcyv4hPCuHBLhSJgZZEh0CbuuJNPLFDA3f-79FX5uVOO0yubA@mail.gmail.com> <20190808065933.GA29382@lst.de> <CAPcyv4hMUzw8vyXFRPe2pdwef0npbMm9tx9wiZ9MWkHGhH1V6w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hMUzw8vyXFRPe2pdwef0npbMm9tx9wiZ9MWkHGhH1V6w@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 06:36:33PM -0700, Dan Williams wrote:
> Section alignment constraints somewhat save us here. The only example
> I can think of a PMD not containing a uniform pgmap association for
> each pte is the case when the pgmap overlaps normal dram, i.e. shares
> the same 'struct memory_section' for a given span. Otherwise, distinct
> pgmaps arrange to manage their own exclusive sections (and now
> subsections as of v5.3). Otherwise the implementation could not
> guarantee different mapping lifetimes.
> 
> That said, this seems to want a better mechanism to determine "pfn is
> ZONE_DEVICE".

So I guess this patch is fine for now, and once you provide a better
mechanism we can switch over to it?

