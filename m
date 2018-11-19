Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E28A26B1BDB
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:39:31 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id u17so6821307pgn.17
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:39:31 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id w9si39438807pgg.72.2018.11.19.10.39.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 10:39:30 -0800 (PST)
Date: Mon, 19 Nov 2018 11:36:13 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH 6/7] acpi: Create subtable parsing infrastructure
Message-ID: <20181119183613.GB26707@localhost.localdomain>
References: <20181114224921.12123-2-keith.busch@intel.com>
 <20181114224921.12123-7-keith.busch@intel.com>
 <CAJZ5v0gQCpmRHdSS=xxLSx-+1xbexSFQb_ZxMvZuKUjk6+w5ww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJZ5v0gQCpmRHdSS=xxLSx-+1xbexSFQb_ZxMvZuKUjk6+w5ww@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Mon, Nov 19, 2018 at 10:58:12AM +0100, Rafael J. Wysocki wrote:
> > +static unsigned long __init
> > +acpi_get_entry_length(struct acpi_subtable_entry *entry)
> > +{
> > +       switch (entry->type) {
> > +       case ACPI_SUBTABLE_COMMON:
> > +               return entry->hdr->common.length;
> > +       }
> > +       WARN_ONCE(1, "invalid acpi type\n");
> 
> AFAICS this does a WARN_ONCE() on information obtained from firmware.
> 
> That is not a kernel problem, so generating traces in that case is not
> a good idea IMO.  Moreover, users can't really do much about this in
> the majority of cases, so a pr_info() message should be sufficient.

Sure thing, I'll fix that up for the next revision.
