Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4A18E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 15:44:04 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id v72so9388594pgb.10
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:44:04 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e35si5535027pgb.548.2019.01.18.12.44.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 12:44:02 -0800 (PST)
Date: Fri, 18 Jan 2019 13:42:51 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCHv4 05/13] Documentation/ABI: Add new node sysfs attributes
Message-ID: <20190118204251.GI31543@localhost.localdomain>
References: <20190116175804.30196-1-keith.busch@intel.com>
 <20190116175804.30196-6-keith.busch@intel.com>
 <CAJZ5v0jmkyrNBHzqHsOuWjLXF34tq83VnEhdBWrdFqxyiXC=cw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJZ5v0jmkyrNBHzqHsOuWjLXF34tq83VnEhdBWrdFqxyiXC=cw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Jan 17, 2019 at 12:41:19PM +0100, Rafael J. Wysocki wrote:
> On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
> >
> > Add entries for memory initiator and target node class attributes.
> >
> > Signed-off-by: Keith Busch <keith.busch@intel.com>
> 
> I would recommend combining this with the previous patch, as the way
> it is now I need to look at two patches at the time. :-)

Will do.
 
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

I think it actually does make sense to use "%*pbl" format here. The
type we're displaying is a bit array, so this is one value for that
attribute. There are many precedents for disapling bit arrays this
way. The existing node attributes that we're appending to show cpu
lists, and the top loevel shows node lists for "possible", "online",
"has_memory", "has_cpu". This new attribute should fit well with
exisiting similar attributes from this subsystem.
 
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

I think that makes sense, I'll take try out this suggestion.
 
> And, of course, the symlinks part needs to be documented as well.  I
> guess you can follow the
> Documentation/ABI/testing/sysfs-devices-power_resources_D0 with that.
