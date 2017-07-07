Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB1456B02F4
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 12:32:15 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s70so37647856pfs.5
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 09:32:15 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id i133si2582264pgc.544.2017.07.07.09.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 09:32:15 -0700 (PDT)
Date: Fri, 7 Jul 2017 10:32:13 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [RFC v2 3/5] hmem: add heterogeneous memory sysfs support
Message-ID: <20170707163213.GC22856@linux.intel.com>
References: <20170706215233.11329-1-ross.zwisler@linux.intel.com>
 <20170706215233.11329-4-ross.zwisler@linux.intel.com>
 <9ea40a37-3549-2294-8605-036b37aec023@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9ea40a37-3549-2294-8605-036b37aec023@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jerome Glisse <jglisse@redhat.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Thu, Jul 06, 2017 at 10:53:39PM -0700, John Hubbard wrote:
> On 07/06/2017 02:52 PM, Ross Zwisler wrote:
> [...]
> > diff --git a/drivers/acpi/Makefile b/drivers/acpi/Makefile
> > index b1aacfc..31e3f20 100644
> > --- a/drivers/acpi/Makefile
> > +++ b/drivers/acpi/Makefile
> > @@ -72,6 +72,7 @@ obj-$(CONFIG_ACPI_PROCESSOR)	+= processor.o
> >  obj-$(CONFIG_ACPI)		+= container.o
> >  obj-$(CONFIG_ACPI_THERMAL)	+= thermal.o
> >  obj-$(CONFIG_ACPI_NFIT)		+= nfit/
> > +obj-$(CONFIG_ACPI_HMEM)		+= hmem/
> >  obj-$(CONFIG_ACPI)		+= acpi_memhotplug.o
> >  obj-$(CONFIG_ACPI_HOTPLUG_IOAPIC) += ioapic.o
> >  obj-$(CONFIG_ACPI_BATTERY)	+= battery.o
> 
> Hi Ross,
> 
> Following are a series of suggestions, intended to clarify naming just
> enough so that, when Jerome's HMM patchset lands, we'll be able to
> tell the difference between the two types of Heterogeneous Memory.

Sure, these all seem sane to me, thanks.  I'll fix this up in v3.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
