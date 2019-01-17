Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id E49978E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:01:39 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id r131so3577420oia.7
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 09:01:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c93sor1036165otb.123.2019.01.17.09.01.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 09:01:38 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-7-keith.busch@intel.com>
 <CAJZ5v0jg24sNVQiA1AvVwP-uCCq1Uo9rxkAERyb_zDL_W8AATA@mail.gmail.com>
In-Reply-To: <CAJZ5v0jg24sNVQiA1AvVwP-uCCq1Uo9rxkAERyb_zDL_W8AATA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 17 Jan 2019 09:01:27 -0800
Message-ID: <CAPcyv4i9Doi_cE8KkB-PjzPyU2GoscvJbKTJzaX1esVQQ=dxMA@mail.gmail.com>
Subject: Re: [PATCHv4 06/13] acpi/hmat: Register processor domain to its memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Keith Busch <keith.busch@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave.hansen@intel.com>

On Thu, Jan 17, 2019 at 4:11 AM Rafael J. Wysocki <rafael@kernel.org> wrote:
>
>     On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
> >
> > If the HMAT Subsystem Address Range provides a valid processor proximity
> > domain for a memory domain, or a processor domain with the highest
> > performing access exists, register the memory target with that initiator
> > so this relationship will be visible under the node's sysfs directory.
> >
> > Since HMAT requires valid address ranges have an equivalent SRAT entry,
> > verify each memory target satisfies this requirement.
>
> What exactly will happen after this patch?
>
> There will be some new directories under
> /sys/devices/system/node/nodeX/ if all goes well.  Anything else?

When / if the memory randomization series [1] makes its way upstream
there will be a follow-on patch to enable that randomization based on
the presence of a memory-side cache published in the HMAT.

[1]: https://lwn.net/Articles/767614/
