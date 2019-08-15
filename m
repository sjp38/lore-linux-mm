Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 233D0C3A59B
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:33:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05083217F4
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:33:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05083217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5963C6B0008; Thu, 15 Aug 2019 16:33:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 546F06B000C; Thu, 15 Aug 2019 16:33:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45DBA6B026A; Thu, 15 Aug 2019 16:33:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0002.hostedemail.com [216.40.44.2])
	by kanga.kvack.org (Postfix) with ESMTP id 270B76B0008
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:33:12 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D8F5A8248AAF
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:33:11 +0000 (UTC)
X-FDA: 75825811782.02.bed22_1bda3399e4430
X-HE-Tag: bed22_1bda3399e4430
X-Filterd-Recvd-Size: 7510
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:33:11 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F129530821A8;
	Thu, 15 Aug 2019 20:33:09 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8E0DE5DA8B;
	Thu, 15 Aug 2019 20:33:08 +0000 (UTC)
Date: Thu, 15 Aug 2019 16:33:06 -0400
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
Message-ID: <20190815203306.GB25517@redhat.com>
References: <CAPcyv4hPCuHBLhSJgZZEh0CbuuJNPLFDA3f-79FX5uVOO0yubA@mail.gmail.com>
 <20190808065933.GA29382@lst.de>
 <CAPcyv4hMUzw8vyXFRPe2pdwef0npbMm9tx9wiZ9MWkHGhH1V6w@mail.gmail.com>
 <20190814073854.GA27249@lst.de>
 <20190814132746.GE13756@mellanox.com>
 <CAPcyv4g8usp8prJ+1bMtyV1xuedp5FKErBp-N8+KzR=rJ-v0QQ@mail.gmail.com>
 <20190815180325.GA4920@redhat.com>
 <CAPcyv4g4hzcEA=TPYVTiqpbtOoS30ahogRUttCvQAvXQbQjfnw@mail.gmail.com>
 <20190815194339.GC9253@redhat.com>
 <CAPcyv4jid8_=-8hBpn_Qm=c4S8BapL9B9RGT7e9uu303yH=Yqw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <CAPcyv4jid8_=-8hBpn_Qm=c4S8BapL9B9RGT7e9uu303yH=Yqw@mail.gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Thu, 15 Aug 2019 20:33:10 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 01:12:22PM -0700, Dan Williams wrote:
> On Thu, Aug 15, 2019 at 12:44 PM Jerome Glisse <jglisse@redhat.com> wro=
te:
> >
> > On Thu, Aug 15, 2019 at 12:36:58PM -0700, Dan Williams wrote:
> > > On Thu, Aug 15, 2019 at 11:07 AM Jerome Glisse <jglisse@redhat.com>=
 wrote:
> > > >
> > > > On Wed, Aug 14, 2019 at 07:48:28AM -0700, Dan Williams wrote:
> > > > > On Wed, Aug 14, 2019 at 6:28 AM Jason Gunthorpe <jgg@mellanox.c=
om> wrote:
> > > > > >
> > > > > > On Wed, Aug 14, 2019 at 09:38:54AM +0200, Christoph Hellwig w=
rote:
> > > > > > > On Tue, Aug 13, 2019 at 06:36:33PM -0700, Dan Williams wrot=
e:
> > > > > > > > Section alignment constraints somewhat save us here. The =
only example
> > > > > > > > I can think of a PMD not containing a uniform pgmap assoc=
iation for
> > > > > > > > each pte is the case when the pgmap overlaps normal dram,=
 i.e. shares
> > > > > > > > the same 'struct memory_section' for a given span. Otherw=
ise, distinct
> > > > > > > > pgmaps arrange to manage their own exclusive sections (an=
d now
> > > > > > > > subsections as of v5.3). Otherwise the implementation cou=
ld not
> > > > > > > > guarantee different mapping lifetimes.
> > > > > > > >
> > > > > > > > That said, this seems to want a better mechanism to deter=
mine "pfn is
> > > > > > > > ZONE_DEVICE".
> > > > > > >
> > > > > > > So I guess this patch is fine for now, and once you provide=
 a better
> > > > > > > mechanism we can switch over to it?
> > > > > >
> > > > > > What about the version I sent to just get rid of all the stra=
nge
> > > > > > put_dev_pagemaps while scanning? Odds are good we will work w=
ith only
> > > > > > a single pagemap, so it makes some sense to cache it once we =
find it?
> > > > >
> > > > > Yes, if the scan is over a single pmd then caching it makes sen=
se.
> > > >
> > > > Quite frankly an easier an better solution is to remove the pagem=
ap
> > > > lookup as HMM user abide by mmu notifier it means we will not mak=
e
> > > > use or dereference the struct page so that we are safe from any
> > > > racing hotunplug of dax memory (as long as device driver using hm=
m
> > > > do not have a bug).
> > >
> > > Yes, as long as the driver remove is synchronized against HMM
> > > operations via another mechanism then there is no need to take page=
map
> > > references. Can you briefly describe what that other mechanism is?
> >
> > So if you hotunplug some dax memory i assume that this can only
> > happens once all the pages are unmapped (as it must have the
> > zero refcount, well 1 because of the bias) and any unmap will
> > trigger a mmu notifier callback. User of hmm mirror abiding by
> > the API will never make use of information they get through the
> > fault or snapshot function until checking for racing notifier
> > under lock.
>=20
> Hmm that first assumption is not guaranteed by the dev_pagemap core.
> The dev_pagemap end of life model is "disable, invalidate, drain" so
> it's possible to call devm_munmap_pages() while pages are still mapped
> it just won't complete the teardown of the pagemap until the last
> reference is dropped. New references are blocked during this teardown.
>=20
> However, if the driver is validating the liveness of the mapping in
> the mmu-notifier path and blocking new references it sounds like it
> should be ok. Might there be GPU driver unit tests that cover this
> racing teardown case?

So nor HMM nor driver should dereference the struct page (i do not
think any iommu driver would either), they only care about the pfn.
So even if we race with a teardown as soon as we get the mmu notifier
callback to invalidate the mmapping we will do so. The pattern is:

    mydriver_populate_vaddr_range(start, end) {
        hmm_range_register(range, start, end)
    again:
        ret =3D hmm_range_fault(start, end)
        if (ret < 0)
            return ret;

        take_driver_page_table_lock();
        if (range.valid) {
            populate_device_page_table();
            release_driver_page_table_lock();
        } else {
            release_driver_page_table_lock();
            goto again;
        }
    }

The mmu notifier callback do use the same page table lock and we
also have the range tracking going on. So either we populate
device page table before racing with teardown in which case the
device page table entry are clear through the mmu notifier call
back. Or if we race, but then we can see the racing mmu notifier
calls and retry again which will trigger a regular page fault
which will return an error i assume.

So in the end we have the exact same behavior as if a CPU was trying
to access that virtual address. This is the whole point of HMM, to
behave exactly as if it was a CPU access. Fails in the same way,
race in the same way. So if DAX teardown are safe versus racing
CPU access to some vma that have that memory map, it will be the
same for HMM users.


GPU driver test suite are not good at testing this. They are geared
to test the GPU itself not the interaction of the GPU driver with
rest of the kernel.

Cheers,
J=E9r=F4me

