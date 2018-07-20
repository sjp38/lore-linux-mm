Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 19C616B026B
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 16:17:10 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g7-v6so9326623qtp.19
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 13:17:10 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f16-v6si2690761qkm.232.2018.07.20.13.17.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 13:17:09 -0700 (PDT)
Date: Fri, 20 Jul 2018 16:17:07 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v4 0/8] mm: Rework hmm to use devm_memremap_pages and
 other fixes
Message-ID: <20180720201706.GE7697@redhat.com>
References: <37267986-A987-4AD7-96CE-C1D2F116A4AC@sinenomine.net>
 <20180720125146.02db0f40b4edc716c6f080d2@linux-foundation.org>
 <20180720195746.GD7697@redhat.com>
 <20180720200124.GB2736@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180720200124.GB2736@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Vitale <mvitale@sinenomine.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.org>, Joe Gorse <jgorse@sinenomine.net>, "release-team@openafs.org" <release-team@openafs.org>

On Fri, Jul 20, 2018 at 01:01:24PM -0700, Matthew Wilcox wrote:
> On Fri, Jul 20, 2018 at 03:57:47PM -0400, Jerome Glisse wrote:
> > On Fri, Jul 20, 2018 at 12:51:46PM -0700, Andrew Morton wrote:
> > > Problem is, that patch is eighth in a series which we're waiting for
> > > Jerome to review and the changelog starts with "Now that all producers
> > > of dev_pagemap instances in the kernel are properly converted to
> > > EXPORT_SYMBOL_GPL...".
> > 
> > I am fine with the patchset modulo GPL, i did review it in the past
> > but i did not formaly reply as i was opose to the GPL changes. So my
> > only objection is with the GPL export, everything else looks fine.
> 
> Everyone from the mm side who's looked at these patches agrees that it
> reaches far too far into the guts of the mm to be anything other than
> exposing internals.  It's not credible to claim that a module written that
> uses these interfaces is anything other than a derived work of the kernel.
> 
> I feel these patches should be merged over Jerome's objections.

I feel that people do not understand how far reaching this is. It means
that any new devices with memory supporting new system bus like CAPI or
CCIX will need to have a GPL driver. This is a departure of current
state of affair where we allow non GPL driver to exist.

Moreover I have argue that HMM abstract the internal mm and by doing so
allow anyone to update the mm code without having to worried about driver
which use HMM. Thus disproving that user of HMM are tie to mm internal.


Also to make thing perfectly clear i am a strong proponent of open
source and i rather have a GPL driver but at the same time i do not want
linux kernel to become second citizen because it can not support new
devices ...


Cheers,
Jerome
