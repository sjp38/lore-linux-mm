Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0B18E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 12:09:02 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id y88so2411266pfi.9
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 09:09:02 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d189si3478568pgc.393.2019.01.15.09.08.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 09:09:01 -0800 (PST)
Date: Tue, 15 Jan 2019 10:07:42 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCHv3 03/13] acpi/hmat: Parse and report heterogeneous memory
Message-ID: <20190115170741.GB27730@localhost.localdomain>
References: <20190109174341.19818-1-keith.busch@intel.com>
 <20190109174341.19818-4-keith.busch@intel.com>
 <CAJZ5v0jk7ML21zxGwf9GaGNK8tP1LAs6Rd9NTK5O9HbzYeyPLA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJZ5v0jk7ML21zxGwf9GaGNK8tP1LAs6Rd9NTK5O9HbzYeyPLA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>

On Thu, Jan 10, 2019 at 07:42:46AM -0800, Rafael J. Wysocki wrote:
> On Wed, Jan 9, 2019 at 6:47 PM Keith Busch <keith.busch@intel.com> wrote:
> >
> > Systems may provide different memory types and export this information
> > in the ACPI Heterogeneous Memory Attribute Table (HMAT). Parse these
> > tables provided by the platform and report the memory access and caching
> > attributes.
> >
> > Signed-off-by: Keith Busch <keith.busch@intel.com>
> 
> While this is generally fine by me, it's another piece of code going
> under drivers/acpi/ just because it happens to use ACPI to extract
> some information from the platform firmware.
> 
> Isn't there any better place for it?

I've tried to abstract the user visible parts outside any particular
firmware implementation, but HMAT parsing is an ACPI specific feature,
so I thought ACPI was a good home for this part. I'm open to suggestions
if there's a better place. Either under in another existing subsystem,
or create a new one under drivers/hmat/?
