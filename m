Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id B49828E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 16:08:15 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id o13so6787945otl.20
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 13:08:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m81sor3289783oib.32.2019.01.18.13.08.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 Jan 2019 13:08:13 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-6-keith.busch@intel.com>
 <CAJZ5v0jmkyrNBHzqHsOuWjLXF34tq83VnEhdBWrdFqxyiXC=cw@mail.gmail.com>
In-Reply-To: <CAJZ5v0jmkyrNBHzqHsOuWjLXF34tq83VnEhdBWrdFqxyiXC=cw@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 18 Jan 2019 13:08:02 -0800
Message-ID: <CAPcyv4gH0_e_NFJNOFH4XXarSs7+TOj4nT0r-D33ZGNCfqBdxg@mail.gmail.com>
Subject: Re: [PATCHv4 05/13] Documentation/ABI: Add new node sysfs attributes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Keith Busch <keith.busch@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave.hansen@intel.com>

On Thu, Jan 17, 2019 at 3:41 AM Rafael J. Wysocki <rafael@kernel.org> wrote:
>
> On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
> >
> > Add entries for memory initiator and target node class attributes.
> >
> > Signed-off-by: Keith Busch <keith.busch@intel.com>
>
> I would recommend combining this with the previous patch, as the way
> it is now I need to look at two patches at the time. :-)
>
> > ---
> >  Documentation/ABI/stable/sysfs-devices-node | 25 ++++++++++++++++++++++++-
> >  1 file changed, 24 insertions(+), 1 deletion(-)
> >
> > diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> > index 3e90e1f3bf0a..a9c47b4b0eee 100644
> > --- a/Documentation/ABI/stable/sysfs-devices-node
> > +++ b/Documentation/ABI/stable/sysfs-devices-node
> > @@ -90,4 +90,27 @@ Date:                December 2009
> >  Contact:       Lee Schermerhorn <lee.schermerhorn@hp.com>
> >  Description:
> >                 The node's huge page size control/query attributes.
> > -               See Documentation/admin-guide/mm/hugetlbpage.rst
> > \ No newline at end of file
> > +               See Documentation/admin-guide/mm/hugetlbpage.rst
> > +
> > +What:          /sys/devices/system/node/nodeX/classY/
> > +Date:          December 2018
> > +Contact:       Keith Busch <keith.busch@intel.com>
> > +Description:
> > +               The node's relationship to other nodes for access class "Y".
> > +
> > +What:          /sys/devices/system/node/nodeX/classY/initiator_nodelist
> > +Date:          December 2018
> > +Contact:       Keith Busch <keith.busch@intel.com>
> > +Description:
> > +               The node list of memory initiators that have class "Y" access
> > +               to this node's memory. CPUs and other memory initiators in
> > +               nodes not in the list accessing this node's memory may have
> > +               different performance.
>
> This does not follow the general "one value per file" rule of sysfs (I
> know that there are other sysfs files with more than one value in
> them, but it is better to follow this rule as long as that makes
> sense).
>
> > +
> > +What:          /sys/devices/system/node/nodeX/classY/target_nodelist
> > +Date:          December 2018
> > +Contact:       Keith Busch <keith.busch@intel.com>
> > +Description:
> > +               The node list of memory targets that this initiator node has
> > +               class "Y" access. Memory accesses from this node to nodes not
> > +               in this list may have differet performance.
> > --
>
> Same here.
>
> And if you follow the recommendation given in the previous message
> (add "initiators" and "targets" subdirs under "classX"), you won't
> even need the two files above.

This recommendation is in conflict with Greg's feedback about kobject
usage. If these are just "vanity" subdirs I think it's better to have
a multi-value sysfs file. This "list" style is already commonplace for
the /sys/devices/system hierarchy.
