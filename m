Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 558BC6B02F3
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 12:31:02 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t75so39131648pgb.0
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 09:31:02 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b3si2814606pld.395.2017.07.07.09.31.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 09:31:00 -0700 (PDT)
Date: Fri, 7 Jul 2017 10:30:58 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [RFC v2 0/5] surface heterogeneous memory performance information
Message-ID: <20170707163058.GB22856@linux.intel.com>
References: <20170706215233.11329-1-ross.zwisler@linux.intel.com>
 <7cb3b9c4-9082-97e9-ebfd-542243bf652b@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7cb3b9c4-9082-97e9-ebfd-542243bf652b@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jerome Glisse <jglisse@redhat.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Thu, Jul 06, 2017 at 10:30:46PM -0700, John Hubbard wrote:
> On 07/06/2017 02:52 PM, Ross Zwisler wrote:
> [...]
> > 
> > The naming collision between Jerome's "Heterogeneous Memory Management
> > (HMM)" and this "Heterogeneous Memory (HMEM)" series is unfortunate, but I
> > was trying to stick with the word "Heterogeneous" because of the naming of
> > the ACPI 6.2 Heterogeneous Memory Attribute Table table.  Suggestions for
> > better naming are welcome.
> > 
> 
> Hi Ross,
> 
> Say, most of the places (file names, function and variable names, and even
> print statements) where this patchset uses hmem or HMEM, it really seems to
> mean, the Heterogeneous Memory Attribute Table. That's not *always* true, but
> given that it's a pretty severe naming conflict, how about just changing:
> 
> hmem --> hmat
> HMEM --> HMAT
> 
> ...everywhere? Then you still have Heterogeneous Memory in the name, but
> there is enough lexical distance (is that a thing? haha) between HMM and HMAT
> to keep us all sane. :)
> 
> With or without the above suggestion, there are a few places (Kconfig, comments,
> prints) where we can more easily make it clear that HMM != HMEM (or HMAT), 
> so for those I can just comment on them separately in the individual patches.
> 
> thanks,
> john h

Hi John,

Sure, that change makes sense to me.  I had initially tried to make this
enabling more generic so that other, non-ACPI systems could use the same sysfs
representation even if they got their performance numbers from some other
source, but while implementing it pretty quickly became very tightly tied to
the ACPI HMAT.

- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
