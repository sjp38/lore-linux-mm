Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA1516B0275
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 13:01:04 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r81-v6so11933642pfk.11
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 10:01:04 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 6-v6si1688348plb.230.2018.10.12.10.01.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 10:01:03 -0700 (PDT)
Date: Fri, 12 Oct 2018 10:58:04 -0600
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCHv2] mm/gup: Cache dev_pagemap while pinning pages
Message-ID: <20181012165803.GB15490@localhost.localdomain>
References: <20181011175542.13045-1-keith.busch@intel.com>
 <CAPcyv4gGqhGpR8g-HmNzoEnMAysO5uAO+8njeAokHq2CT9x71A@mail.gmail.com>
 <20181012110020.pu5oanl6tnz4mibr@kshutemo-mobl1>
 <CAPcyv4jiWD0V1uqrPRvcGJWZr2qZ-MwrY6O=CDmqmfANhokJyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jiWD0V1uqrPRvcGJWZr2qZ-MwrY6O=CDmqmfANhokJyw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Oct 12, 2018 at 09:58:18AM -0700, Dan Williams wrote:
> On Fri, Oct 12, 2018 at 4:00 AM Kirill A. Shutemov <kirill@shutemov.name> wrote:
> [..]
> > > Does this have defined behavior? I would feel better with " = { 0 }"
> > > to be explicit.
> >
> > Well, it's not allowed by the standart, but GCC allows this.
> > You can see a warning with -pedantic.
> >
> > We use empty-list initializers a lot in the kernel:
> > $ git grep 'struct .*= {};' | wc -l
> > 997
> >
> > It should be fine.
> 
> Ah, ok. I would still say we should be consistent between the init
> syntax for 'ctx' in follow_page() and __get_user_pages(), and why not
> go with '= { 0 }', one less unnecessary gcc'ism.

No problem, I'll make that happen and copy your reviews/acks into the
next patch.
