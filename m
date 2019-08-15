Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5A3CC41514
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:43:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92ADC2083B
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:43:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92ADC2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BF7C6B026B; Thu, 15 Aug 2019 15:43:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 349CD6B027A; Thu, 15 Aug 2019 15:43:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 210F06B0281; Thu, 15 Aug 2019 15:43:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0241.hostedemail.com [216.40.44.241])
	by kanga.kvack.org (Postfix) with ESMTP id F2A496B026B
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:43:45 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id AC12A180AD7C1
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:43:45 +0000 (UTC)
X-FDA: 75825687210.04.wrist84_20c795c610f2b
X-HE-Tag: wrist84_20c795c610f2b
X-Filterd-Recvd-Size: 4856
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:43:45 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3690B300C72E;
	Thu, 15 Aug 2019 19:43:44 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6F4BA177C5;
	Thu, 15 Aug 2019 19:43:41 +0000 (UTC)
Date: Thu, 15 Aug 2019 15:43:39 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 04/15] mm: remove the pgmap field from struct hmm_vma_walk
Message-ID: <20190815194339.GC9253@redhat.com>
References: <20190806160554.14046-5-hch@lst.de>
 <20190807174548.GJ1571@mellanox.com>
 <CAPcyv4hPCuHBLhSJgZZEh0CbuuJNPLFDA3f-79FX5uVOO0yubA@mail.gmail.com>
 <20190808065933.GA29382@lst.de>
 <CAPcyv4hMUzw8vyXFRPe2pdwef0npbMm9tx9wiZ9MWkHGhH1V6w@mail.gmail.com>
 <20190814073854.GA27249@lst.de>
 <20190814132746.GE13756@mellanox.com>
 <CAPcyv4g8usp8prJ+1bMtyV1xuedp5FKErBp-N8+KzR=rJ-v0QQ@mail.gmail.com>
 <20190815180325.GA4920@redhat.com>
 <CAPcyv4g4hzcEA=TPYVTiqpbtOoS30ahogRUttCvQAvXQbQjfnw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <CAPcyv4g4hzcEA=TPYVTiqpbtOoS30ahogRUttCvQAvXQbQjfnw@mail.gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Thu, 15 Aug 2019 19:43:44 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 12:36:58PM -0700, Dan Williams wrote:
> On Thu, Aug 15, 2019 at 11:07 AM Jerome Glisse <jglisse@redhat.com> wro=
te:
> >
> > On Wed, Aug 14, 2019 at 07:48:28AM -0700, Dan Williams wrote:
> > > On Wed, Aug 14, 2019 at 6:28 AM Jason Gunthorpe <jgg@mellanox.com> =
wrote:
> > > >
> > > > On Wed, Aug 14, 2019 at 09:38:54AM +0200, Christoph Hellwig wrote=
:
> > > > > On Tue, Aug 13, 2019 at 06:36:33PM -0700, Dan Williams wrote:
> > > > > > Section alignment constraints somewhat save us here. The only=
 example
> > > > > > I can think of a PMD not containing a uniform pgmap associati=
on for
> > > > > > each pte is the case when the pgmap overlaps normal dram, i.e=
. shares
> > > > > > the same 'struct memory_section' for a given span. Otherwise,=
 distinct
> > > > > > pgmaps arrange to manage their own exclusive sections (and no=
w
> > > > > > subsections as of v5.3). Otherwise the implementation could n=
ot
> > > > > > guarantee different mapping lifetimes.
> > > > > >
> > > > > > That said, this seems to want a better mechanism to determine=
 "pfn is
> > > > > > ZONE_DEVICE".
> > > > >
> > > > > So I guess this patch is fine for now, and once you provide a b=
etter
> > > > > mechanism we can switch over to it?
> > > >
> > > > What about the version I sent to just get rid of all the strange
> > > > put_dev_pagemaps while scanning? Odds are good we will work with =
only
> > > > a single pagemap, so it makes some sense to cache it once we find=
 it?
> > >
> > > Yes, if the scan is over a single pmd then caching it makes sense.
> >
> > Quite frankly an easier an better solution is to remove the pagemap
> > lookup as HMM user abide by mmu notifier it means we will not make
> > use or dereference the struct page so that we are safe from any
> > racing hotunplug of dax memory (as long as device driver using hmm
> > do not have a bug).
>=20
> Yes, as long as the driver remove is synchronized against HMM
> operations via another mechanism then there is no need to take pagemap
> references. Can you briefly describe what that other mechanism is?

So if you hotunplug some dax memory i assume that this can only
happens once all the pages are unmapped (as it must have the
zero refcount, well 1 because of the bias) and any unmap will
trigger a mmu notifier callback. User of hmm mirror abiding by
the API will never make use of information they get through the
fault or snapshot function until checking for racing notifier
under lock.

Cheers,
J=E9r=F4me

