Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8C48C6B0008
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 16:01:30 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 70-v6so8176597plc.1
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 13:01:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e93-v6si2384268plb.135.2018.07.20.13.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 20 Jul 2018 13:01:29 -0700 (PDT)
Date: Fri, 20 Jul 2018 13:01:24 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 0/8] mm: Rework hmm to use devm_memremap_pages and
 other fixes
Message-ID: <20180720200124.GB2736@bombadil.infradead.org>
References: <37267986-A987-4AD7-96CE-C1D2F116A4AC@sinenomine.net>
 <20180720125146.02db0f40b4edc716c6f080d2@linux-foundation.org>
 <20180720195746.GD7697@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180720195746.GD7697@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Vitale <mvitale@sinenomine.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.org>, Joe Gorse <jgorse@sinenomine.net>, "release-team@openafs.org" <release-team@openafs.org>

On Fri, Jul 20, 2018 at 03:57:47PM -0400, Jerome Glisse wrote:
> On Fri, Jul 20, 2018 at 12:51:46PM -0700, Andrew Morton wrote:
> > Problem is, that patch is eighth in a series which we're waiting for
> > Jerome to review and the changelog starts with "Now that all producers
> > of dev_pagemap instances in the kernel are properly converted to
> > EXPORT_SYMBOL_GPL...".
> 
> I am fine with the patchset modulo GPL, i did review it in the past
> but i did not formaly reply as i was opose to the GPL changes. So my
> only objection is with the GPL export, everything else looks fine.

Everyone from the mm side who's looked at these patches agrees that it
reaches far too far into the guts of the mm to be anything other than
exposing internals.  It's not credible to claim that a module written that
uses these interfaces is anything other than a derived work of the kernel.

I feel these patches should be merged over Jerome's objections.
