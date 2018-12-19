Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id E92DA8E0007
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 19:00:00 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id s140so2046770oih.4
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 16:00:00 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l9sor4882217otj.49.2018.12.19.15.59.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 15:59:59 -0800 (PST)
MIME-Version: 1.0
References: <20181211010310.8551-1-keith.busch@intel.com> <20181211010310.8551-2-keith.busch@intel.com>
 <CAJZ5v0iqC2CwR2nM7eF6pDcJe2Me-_fFekX=s16-1TGZ6f6gcA@mail.gmail.com> <CF6A88132359CE47947DB4C6E1709ED53C557D62@ORSMSX122.amr.corp.intel.com>
In-Reply-To: <CF6A88132359CE47947DB4C6E1709ED53C557D62@ORSMSX122.amr.corp.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 19 Dec 2018 15:59:48 -0800
Message-ID: <CAPcyv4jmGH0FS8iBP9=A-nicNfgHAmU+nBHsGgxyS3RNZ9tV5Q@mail.gmail.com>
Subject: Re: [PATCHv2 01/12] acpi: Create subtable parsing infrastructure
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Schmauss, Erik" <erik.schmauss@intel.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, "Busch, Keith" <keith.busch@intel.com>, "Moore, Robert" <robert.moore@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Hansen, Dave" <dave.hansen@intel.com>

On Wed, Dec 19, 2018 at 3:19 PM Schmauss, Erik <erik.schmauss@intel.com> wrote:
>
>
>
> > -----Original Message-----
> > From: linux-acpi-owner@vger.kernel.org [mailto:linux-acpi-
> > owner@vger.kernel.org] On Behalf Of Rafael J. Wysocki
> > Sent: Tuesday, December 11, 2018 1:45 AM
> > To: Busch, Keith <keith.busch@intel.com>
> > Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>; ACPI Devel
> > Maling List <linux-acpi@vger.kernel.org>; Linux Memory Management List
> > <linux-mm@kvack.org>; Greg Kroah-Hartman
> > <gregkh@linuxfoundation.org>; Rafael J. Wysocki <rafael@kernel.org>;
> > Hansen, Dave <dave.hansen@intel.com>; Williams, Dan J
> > <dan.j.williams@intel.com>
> > Subject: Re: [PATCHv2 01/12] acpi: Create subtable parsing infrastructure
> >
> > On Tue, Dec 11, 2018 at 2:05 AM Keith Busch <keith.busch@intel.com>
> > wrote:
> > >
>
> Hi Rafael and Bob,
>
> > > Parsing entries in an ACPI table had assumed a generic header
> > > structure that is most common. There is no standard ACPI header,
> > > though, so less common types would need custom parsers if they want go
> > > through their sub-table entry list.
> >
> > It looks like the problem at hand is that acpi_hmat_structure is incompatible
> > with acpi_subtable_header because of the different layout and field sizes.
>
> Just out of curiosity, why don't we use ACPICA code to parse static ACPI tables
> in Linux?
>
> We have a disassembler for static tables that parses all supported tables. This
> seems like a duplication of code/effort...

Oh, I thought acpi_table_parse_entries() was the common code. What's
the ACPICA duplicate?
