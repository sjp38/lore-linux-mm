Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 589856B0010
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 13:01:41 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h48-v6so1321414edh.22
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 10:01:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w35-v6si147847edc.217.2018.10.23.10.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 10:01:39 -0700 (PDT)
Date: Tue, 23 Oct 2018 19:01:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 1/7] mm, devm_memremap_pages: Mark
 devm_memremap_pages() EXPORT_SYMBOL_GPL
Message-ID: <20181023170136.GV18839@dhcp22.suse.cz>
References: <153936657159.1198040.4489957977352276272.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153936657702.1198040.119388737535638846.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20181017081753.GG18839@dhcp22.suse.cz>
 <CAPcyv4hMFQYekvZWMzKYckuVLSGd3GizRtoDudFBQj5bfxD3Mw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hMFQYekvZWMzKYckuVLSGd3GizRtoDudFBQj5bfxD3Mw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed 17-10-18 09:30:58, Dan Williams wrote:
> On Wed, Oct 17, 2018 at 1:18 AM Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > > Again, devm_memremap_pagex() exposes and relies upon core kernel
> > > internal assumptions and will continue to evolve along with 'struct
> > > page', memory hotplug, and support for new memory types / topologies.
> > > Only an in-kernel GPL-only driver is expected to keep up with this
> > > ongoing evolution. This interface, and functionality derived from this
> > > interface, is not suitable for kernel-external drivers.
> >
> > I do not follow this line of argumentation though. We generally do not
> > care about out-of-tree modules and breaking them if the interface has to
> > be updated.
> 
> Exactly right. The EXPORT_SYMBOL_GPL is there to say that this api has
> deep enough ties into the core kernel to lower the confidence that the
> API will stay stable from one kernel revision to the next. It's also
> an api that is attracting widening and varied reuse and the long term
> health of the implementation depends on being able to peer deeply into
> its users and refactor the interface and the core kernel as a result.

I am sorry I do not follow. For in-tree modules you have to update users
whether the export is GPL or not and we do not care _at all_ about out
of tree because we do not guarantee _any_ kABI/API stability
(Documentation/process/stable-api-nonsense.rst).

Anyway, I do not really care much, but I find the way of the
argumentation dubious. I can clearly understand a simple line "me as the
author want this GPL - live with that".
-- 
Michal Hocko
SUSE Labs
