Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id E35576B0006
	for <linux-mm@kvack.org>; Sat, 21 Jul 2018 12:11:59 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id o24-v6so10641532iob.20
        for <linux-mm@kvack.org>; Sat, 21 Jul 2018 09:11:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e82-v6sor1313503ioe.350.2018.07.21.09.11.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 21 Jul 2018 09:11:57 -0700 (PDT)
MIME-Version: 1.0
References: <37267986-A987-4AD7-96CE-C1D2F116A4AC@sinenomine.net>
 <20180720125146.02db0f40b4edc716c6f080d2@linux-foundation.org>
 <20180720195746.GD7697@redhat.com> <20180720200124.GB2736@bombadil.infradead.org>
 <20180720201706.GE7697@redhat.com>
In-Reply-To: <20180720201706.GE7697@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 21 Jul 2018 09:11:46 -0700
Message-ID: <CAA9_cmf0tGZJGWWnoBR6078Wy_RUe6OnFChp+DEk5TwE6k1gqQ@mail.gmail.com>
Subject: Re: [PATCH v4 0/8] mm: Rework hmm to use devm_memremap_pages and
 other fixes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, mvitale@sinenomine.net, linux-mm <linux-mm@kvack.org>, dan.j.williams@intel.org, jgorse@sinenomine.net, release-team@openafs.org

On Fri, Jul 20, 2018 at 1:17 PM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Fri, Jul 20, 2018 at 01:01:24PM -0700, Matthew Wilcox wrote:
> > On Fri, Jul 20, 2018 at 03:57:47PM -0400, Jerome Glisse wrote:
> > > On Fri, Jul 20, 2018 at 12:51:46PM -0700, Andrew Morton wrote:
> > > > Problem is, that patch is eighth in a series which we're waiting for
> > > > Jerome to review and the changelog starts with "Now that all producers
> > > > of dev_pagemap instances in the kernel are properly converted to
> > > > EXPORT_SYMBOL_GPL...".
> > >
> > > I am fine with the patchset modulo GPL, i did review it in the past
> > > but i did not formaly reply as i was opose to the GPL changes. So my
> > > only objection is with the GPL export, everything else looks fine.
> >
> > Everyone from the mm side who's looked at these patches agrees that it
> > reaches far too far into the guts of the mm to be anything other than
> > exposing internals.  It's not credible to claim that a module written that
> > uses these interfaces is anything other than a derived work of the kernel.
> >
> > I feel these patches should be merged over Jerome's objections.
>
> I feel that people do not understand how far reaching this is. It means
> that any new devices with memory supporting new system bus like CAPI or
> CCIX will need to have a GPL driver. This is a departure of current
> state of affair where we allow non GPL driver to exist.

Proprietary GPU driver vendors have done just fine without us adding
explicit new mechanisms for them to consume.

> Moreover I have argue that HMM abstract the internal mm and by doing so
> allow anyone to update the mm code without having to worried about driver
> which use HMM. Thus disproving that user of HMM are tie to mm internal.

No, HMM has has deployed a GPL-bypass shim into the kernel.

> Also to make thing perfectly clear i am a strong proponent of open
> source and i rather have a GPL driver but at the same time i do not want
> linux kernel to become second citizen because it can not support new
> devices ...

HMM diminishes the letter and the spirit of EXPORT_SYMBOL_GPL, it
grants access to and consumes GPL-only infrastructure written by me
and others.
