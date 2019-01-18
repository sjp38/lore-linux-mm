Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5128E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 11:36:04 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id o8so6480900otp.16
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 08:36:04 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t22sor3011665oie.57.2019.01.18.08.36.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 Jan 2019 08:36:03 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-6-keith.busch@intel.com>
 <20190118112134.00003b65@huawei.com>
In-Reply-To: <20190118112134.00003b65@huawei.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 18 Jan 2019 08:35:50 -0800
Message-ID: <CAPcyv4jo20LkXnVuLcvxFOOSGhx7yGN1vy4jv3N33ubk0q0nOg@mail.gmail.com>
Subject: Re: [PATCHv4 05/13] Documentation/ABI: Add new node sysfs attributes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: Keith Busch <keith.busch@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Fri, Jan 18, 2019 at 3:22 AM Jonathan Cameron
<jonathan.cameron@huawei.com> wrote:
>
> On Wed, 16 Jan 2019 10:57:56 -0700
> Keith Busch <keith.busch@intel.com> wrote:
>
> > Add entries for memory initiator and target node class attributes.
> >
> > Signed-off-by: Keith Busch <keith.busch@intel.com>
> > ---
> >  Documentation/ABI/stable/sysfs-devices-node | 25 ++++++++++++++++++++++++-
> >  1 file changed, 24 insertions(+), 1 deletion(-)
> >
> > diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> > index 3e90e1f3bf0a..a9c47b4b0eee 100644
> > --- a/Documentation/ABI/stable/sysfs-devices-node
> > +++ b/Documentation/ABI/stable/sysfs-devices-node
> > @@ -90,4 +90,27 @@ Date:              December 2009
> >  Contact:     Lee Schermerhorn <lee.schermerhorn@hp.com>
> >  Description:
> >               The node's huge page size control/query attributes.
> > -             See Documentation/admin-guide/mm/hugetlbpage.rst
> > \ No newline at end of file
> > +             See Documentation/admin-guide/mm/hugetlbpage.rst
> > +
> > +What:                /sys/devices/system/node/nodeX/classY/
> > +Date:                December 2018
> > +Contact:     Keith Busch <keith.busch@intel.com>
> > +Description:
> > +             The node's relationship to other nodes for access class "Y".
> > +
> > +What:                /sys/devices/system/node/nodeX/classY/initiator_nodelist
> > +Date:                December 2018
> > +Contact:     Keith Busch <keith.busch@intel.com>
> > +Description:
> > +             The node list of memory initiators that have class "Y" access
> > +             to this node's memory. CPUs and other memory initiators in
> > +             nodes not in the list accessing this node's memory may have
> > +             different performance.
> > +
> > +What:                /sys/devices/system/node/nodeX/classY/target_nodelist
> > +Date:                December 2018
> > +Contact:     Keith Busch <keith.busch@intel.com>
> > +Description:
> > +             The node list of memory targets that this initiator node has
> > +             class "Y" access. Memory accesses from this node to nodes not
> > +             in this list may have differet performance.
>
> Different performance from what?  In the other thread we established that
> these target_nodelists are kind of a backwards reference, they all have
> their characteristics anyway.  Perhaps this just needs to say:
> "Memory access from this node to these targets may have different performance"?
>
> i.e. Don't make the assumption I did that they should all be the same!

I think a clarification of "class" is needed in this context. A
"class" is the the set of initiators that have the same rated
performance to a given target set. In other words "class" is a tuple
of (performance profile, initiator set, target set). Different
performance creates a different tuple / class.
