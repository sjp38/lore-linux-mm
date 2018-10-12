Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id C14596B026A
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 12:58:30 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id y34so8966507oti.1
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 09:58:30 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 135-v6sor993768oia.49.2018.10.12.09.58.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Oct 2018 09:58:29 -0700 (PDT)
MIME-Version: 1.0
References: <20181011175542.13045-1-keith.busch@intel.com> <CAPcyv4gGqhGpR8g-HmNzoEnMAysO5uAO+8njeAokHq2CT9x71A@mail.gmail.com>
 <20181012110020.pu5oanl6tnz4mibr@kshutemo-mobl1>
In-Reply-To: <20181012110020.pu5oanl6tnz4mibr@kshutemo-mobl1>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 12 Oct 2018 09:58:18 -0700
Message-ID: <CAPcyv4jiWD0V1uqrPRvcGJWZr2qZ-MwrY6O=CDmqmfANhokJyw@mail.gmail.com>
Subject: Re: [PATCHv2] mm/gup: Cache dev_pagemap while pinning pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Keith Busch <keith.busch@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Oct 12, 2018 at 4:00 AM Kirill A. Shutemov <kirill@shutemov.name> wrote:
[..]
> > Does this have defined behavior? I would feel better with " = { 0 }"
> > to be explicit.
>
> Well, it's not allowed by the standart, but GCC allows this.
> You can see a warning with -pedantic.
>
> We use empty-list initializers a lot in the kernel:
> $ git grep 'struct .*= {};' | wc -l
> 997
>
> It should be fine.

Ah, ok. I would still say we should be consistent between the init
syntax for 'ctx' in follow_page() and __get_user_pages(), and why not
go with '= { 0 }', one less unnecessary gcc'ism.
