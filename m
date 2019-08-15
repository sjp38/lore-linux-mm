Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 314C5C3A59C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:12:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA0AC2089E
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:12:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="qO7wFUVB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA0AC2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DCEA6B0275; Thu, 15 Aug 2019 16:12:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68EFF6B0277; Thu, 15 Aug 2019 16:12:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57D5C6B027A; Thu, 15 Aug 2019 16:12:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0034.hostedemail.com [216.40.44.34])
	by kanga.kvack.org (Postfix) with ESMTP id 371796B0275
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:12:36 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id DBCF875A6
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:12:35 +0000 (UTC)
X-FDA: 75825759870.15.paint80_8af5f13c39e57
X-HE-Tag: paint80_8af5f13c39e57
X-Filterd-Recvd-Size: 6757
Received: from mail-ot1-f67.google.com (mail-ot1-f67.google.com [209.85.210.67])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:12:34 +0000 (UTC)
Received: by mail-ot1-f67.google.com with SMTP id o101so7561944ota.8
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:12:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=A0+yFoccKuBfbcsXsXsga1tmUthvWenlvN1lT3lVs28=;
        b=qO7wFUVBcfsXZdEWtESTlkgDJFIn+h2Zftaw2r0fFx3myFLMcmx/1PxE8CN+fqldWQ
         zjBl3Dul7mG+AB3phn1DsCwl/3tGds0vBJ1kqEV+ap8hW1PegTxQmwVct4e6eZW5Mfez
         HLsQOrHW17zkzc1s7yiRXL2BVjwVwr/l/20Il9jmjG/teTTaa5j9sARFRpHce+kxtMJS
         6pcaFtAD6i7TvosBx8nv53Etr/AFABojJvFQyvd2/naDP/49htS0fK6O8E2SpX+XvJFi
         LHhffCbJNMAu8GkF3l05nJPd/24PikpQTsobVDta1UgZR+WEGVU1hpgkfCqVY0EkQboc
         34+w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=A0+yFoccKuBfbcsXsXsga1tmUthvWenlvN1lT3lVs28=;
        b=icak8l5LtJcK5fyAJBVUH0C5eWVJ69SuI9wpVainzOjxU6Ftkom+bMhij5a7NCMnq7
         AROo6pN36S9eKSE2syihMGRBzoQHJOK1qZub8qNkRUw4x2BWZUrbAf0xof29qsiRpF7f
         0iTpu6KVKwm9+DCJGOlW/dKf7sq9wLdF4h3k1wm1ayLveQZ9PuSwUDFRDHbV3xXVyE/L
         MGyhUeK7BVo4FzM7RbgvqKENvApgwscjw3lOK+o7rD9GzkxBes15idOFzqzkSfKt6REL
         URQ+1aZyEVP8j8OIqCLlv5LxdQnc3b3Yw8zVIO5rOcdOkwbcVh0A313Xubo9BNi6Msuj
         eHow==
X-Gm-Message-State: APjAAAXqgSLW/G7qyobM/DT8glkTEqK9giTpru8/uoGN9L7oHfv0RFbH
	UrLaQpj0yMyiIDHhdBDVoIM71OtB6bvs2RMV+nUBycaL
X-Google-Smtp-Source: APXvYqwuZcCCvgwgQl2Mb8pVIF/qyxKE2rFZqaszAzmMCreK6bW5n2dN0Ore2hO/padEjUkbv/NUNR4f+frL+RoGGBk=
X-Received: by 2002:a9d:7a9a:: with SMTP id l26mr4370413otn.71.1565899953979;
 Thu, 15 Aug 2019 13:12:33 -0700 (PDT)
MIME-Version: 1.0
References: <20190806160554.14046-5-hch@lst.de> <20190807174548.GJ1571@mellanox.com>
 <CAPcyv4hPCuHBLhSJgZZEh0CbuuJNPLFDA3f-79FX5uVOO0yubA@mail.gmail.com>
 <20190808065933.GA29382@lst.de> <CAPcyv4hMUzw8vyXFRPe2pdwef0npbMm9tx9wiZ9MWkHGhH1V6w@mail.gmail.com>
 <20190814073854.GA27249@lst.de> <20190814132746.GE13756@mellanox.com>
 <CAPcyv4g8usp8prJ+1bMtyV1xuedp5FKErBp-N8+KzR=rJ-v0QQ@mail.gmail.com>
 <20190815180325.GA4920@redhat.com> <CAPcyv4g4hzcEA=TPYVTiqpbtOoS30ahogRUttCvQAvXQbQjfnw@mail.gmail.com>
 <20190815194339.GC9253@redhat.com>
In-Reply-To: <20190815194339.GC9253@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 15 Aug 2019 13:12:22 -0700
Message-ID: <CAPcyv4jid8_=-8hBpn_Qm=c4S8BapL9B9RGT7e9uu303yH=Yqw@mail.gmail.com>
Subject: Re: [PATCH 04/15] mm: remove the pgmap field from struct hmm_vma_walk
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>, Ben Skeggs <bskeggs@redhat.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, 
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 12:44 PM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Thu, Aug 15, 2019 at 12:36:58PM -0700, Dan Williams wrote:
> > On Thu, Aug 15, 2019 at 11:07 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > >
> > > On Wed, Aug 14, 2019 at 07:48:28AM -0700, Dan Williams wrote:
> > > > On Wed, Aug 14, 2019 at 6:28 AM Jason Gunthorpe <jgg@mellanox.com> wrote:
> > > > >
> > > > > On Wed, Aug 14, 2019 at 09:38:54AM +0200, Christoph Hellwig wrote:
> > > > > > On Tue, Aug 13, 2019 at 06:36:33PM -0700, Dan Williams wrote:
> > > > > > > Section alignment constraints somewhat save us here. The only example
> > > > > > > I can think of a PMD not containing a uniform pgmap association for
> > > > > > > each pte is the case when the pgmap overlaps normal dram, i.e. shares
> > > > > > > the same 'struct memory_section' for a given span. Otherwise, distinct
> > > > > > > pgmaps arrange to manage their own exclusive sections (and now
> > > > > > > subsections as of v5.3). Otherwise the implementation could not
> > > > > > > guarantee different mapping lifetimes.
> > > > > > >
> > > > > > > That said, this seems to want a better mechanism to determine "pfn is
> > > > > > > ZONE_DEVICE".
> > > > > >
> > > > > > So I guess this patch is fine for now, and once you provide a better
> > > > > > mechanism we can switch over to it?
> > > > >
> > > > > What about the version I sent to just get rid of all the strange
> > > > > put_dev_pagemaps while scanning? Odds are good we will work with only
> > > > > a single pagemap, so it makes some sense to cache it once we find it?
> > > >
> > > > Yes, if the scan is over a single pmd then caching it makes sense.
> > >
> > > Quite frankly an easier an better solution is to remove the pagemap
> > > lookup as HMM user abide by mmu notifier it means we will not make
> > > use or dereference the struct page so that we are safe from any
> > > racing hotunplug of dax memory (as long as device driver using hmm
> > > do not have a bug).
> >
> > Yes, as long as the driver remove is synchronized against HMM
> > operations via another mechanism then there is no need to take pagemap
> > references. Can you briefly describe what that other mechanism is?
>
> So if you hotunplug some dax memory i assume that this can only
> happens once all the pages are unmapped (as it must have the
> zero refcount, well 1 because of the bias) and any unmap will
> trigger a mmu notifier callback. User of hmm mirror abiding by
> the API will never make use of information they get through the
> fault or snapshot function until checking for racing notifier
> under lock.

Hmm that first assumption is not guaranteed by the dev_pagemap core.
The dev_pagemap end of life model is "disable, invalidate, drain" so
it's possible to call devm_munmap_pages() while pages are still mapped
it just won't complete the teardown of the pagemap until the last
reference is dropped. New references are blocked during this teardown.

However, if the driver is validating the liveness of the mapping in
the mmu-notifier path and blocking new references it sounds like it
should be ok. Might there be GPU driver unit tests that cover this
racing teardown case?

