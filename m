Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4DAA08E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 04:44:45 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id r82so7640616oie.14
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 01:44:45 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n130sor7575856oia.17.2018.12.11.01.44.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 01:44:44 -0800 (PST)
MIME-Version: 1.0
References: <20181211010310.8551-1-keith.busch@intel.com> <20181211010310.8551-2-keith.busch@intel.com>
In-Reply-To: <20181211010310.8551-2-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Tue, 11 Dec 2018 10:44:32 +0100
Message-ID: <CAJZ5v0iqC2CwR2nM7eF6pDcJe2Me-_fFekX=s16-1TGZ6f6gcA@mail.gmail.com>
Subject: Re: [PATCHv2 01/12] acpi: Create subtable parsing infrastructure
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Tue, Dec 11, 2018 at 2:05 AM Keith Busch <keith.busch@intel.com> wrote:
>
> Parsing entries in an ACPI table had assumed a generic header structure
> that is most common. There is no standard ACPI header, though, so less
> common types would need custom parsers if they want go through their
> sub-table entry list.

It looks like the problem at hand is that acpi_hmat_structure is
incompatible with acpi_subtable_header because of the different layout
and field sizes.

If so, please state that clearly here.

With that, please feel free to add

Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

to this patch.
