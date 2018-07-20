Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F95F6B000A
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 15:57:51 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id b8-v6so9202077qto.16
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 12:57:51 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w9-v6si2324962qvk.136.2018.07.20.12.57.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 12:57:50 -0700 (PDT)
Date: Fri, 20 Jul 2018 15:57:47 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v4 0/8] mm: Rework hmm to use devm_memremap_pages and
 other fixes
Message-ID: <20180720195746.GD7697@redhat.com>
References: <37267986-A987-4AD7-96CE-C1D2F116A4AC@sinenomine.net>
 <20180720125146.02db0f40b4edc716c6f080d2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180720125146.02db0f40b4edc716c6f080d2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Vitale <mvitale@sinenomine.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.org>, Joe Gorse <jgorse@sinenomine.net>, "release-team@openafs.org" <release-team@openafs.org>

On Fri, Jul 20, 2018 at 12:51:46PM -0700, Andrew Morton wrote:
> On Fri, 20 Jul 2018 14:43:14 +0000 Mark Vitale <mvitale@sinenomine.net> wrote:
> 
> > On Jul 11, 2018, Dan Williams wrote:
> > > Changes since v3 [1]:
> > > * Collect Logan's reviewed-by on patch 3
> > > * Collect John's and Joe's tested-by on patch 8
> > > * Update the changelog for patch 1 and 7 to better explain the
> > >   EXPORT_SYMBOL_GPL rationale.
> > > * Update the changelog for patch 2 to clarify that it is a cleanup to
> > >   make the following patch-3 fix easier
> > >
> > > [1]: https://lkml.org/lkml/2018/6/19/108
> > >
> > > ---
> > > 
> > > Hi Andrew,
> > > 
> > > As requested, here is a resend of the devm_memremap_pages() fixups.
> > > Please consider for 4.18.
> > 
> > What is the status of this patchset?  OpenAFS is unable to build on
> > Linux 4.18 without the last patch in this set:
> > 
> > 8/8  mm: Fix exports that inadvertently make put_page() EXPORT_SYMBOL_GPL
> > 
> > Will this be merged soon to linux-next, and ultimately to a Linux 4.18 rc?
> > 
> 
> Problem is, that patch is eighth in a series which we're waiting for
> Jerome to review and the changelog starts with "Now that all producers
> of dev_pagemap instances in the kernel are properly converted to
> EXPORT_SYMBOL_GPL...".

I am fine with the patchset modulo GPL, i did review it in the past
but i did not formaly reply as i was opose to the GPL changes. So my
only objection is with the GPL export, everything else looks fine.

I can review once more as it has been more than a month since i last
look at this patchset. I am working with Ben on nouveau right now so
if it breaks anything for me i will fix it once we do our final
rebase before posting.

Cheers,
Jerome
