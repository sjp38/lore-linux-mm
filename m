Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D9B806B0033
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 15:53:40 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q186so7731489pga.23
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 12:53:40 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id s129si5095234pgc.528.2017.12.15.12.53.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 12:53:39 -0800 (PST)
Date: Fri, 15 Dec 2017 13:53:36 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 2/3] hmat: add heterogeneous memory sysfs support
Message-ID: <20171215205336.GB5454@linux.intel.com>
References: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
 <20171214021019.13579-3-ross.zwisler@linux.intel.com>
 <CAJZ5v0h8=mh9BKa2eZzqbc12T6saB+q19yqSfRLYKOiUjS2Cjg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJZ5v0h8=mh9BKa2eZzqbc12T6saB+q19yqSfRLYKOiUjS2Cjg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Koss, Marcin" <marcin.koss@intel.com>, "Koziej, Artur" <artur.koziej@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Brice Goglin <brice.goglin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Fri, Dec 15, 2017 at 01:52:03AM +0100, Rafael J. Wysocki wrote:
<>
> > diff --git a/drivers/acpi/hmat/core.c b/drivers/acpi/hmat/core.c
> > new file mode 100644
> > index 000000000000..61b90dadf84b
> > --- /dev/null
> > +++ b/drivers/acpi/hmat/core.c
> > @@ -0,0 +1,536 @@
> > +/*
> > + * Heterogeneous Memory Attributes Table (HMAT) representation in sysfs
> > + *
> > + * Copyright (c) 2017, Intel Corporation.
> > + *
> > + * This program is free software; you can redistribute it and/or modify it
> > + * under the terms and conditions of the GNU General Public License,
> > + * version 2, as published by the Free Software Foundation.
> > + *
> > + * This program is distributed in the hope it will be useful, but WITHOUT
> > + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> > + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> > + * more details.
> > + */
> 
> Minor nit for starters: you should use SPDX license indentifiers in
> new files and if you do so, the license boilerplace is not necessary
> any more.

Okay, I'll fix that up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
