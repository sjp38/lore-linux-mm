Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id C16488E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 13:36:16 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id d93so1397796otb.12
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 10:36:16 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w23sor2526800otm.189.2019.01.15.10.36.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 10:36:15 -0800 (PST)
MIME-Version: 1.0
References: <20190109174341.19818-1-keith.busch@intel.com> <20190109174341.19818-4-keith.busch@intel.com>
 <CAJZ5v0jk7ML21zxGwf9GaGNK8tP1LAs6Rd9NTK5O9HbzYeyPLA@mail.gmail.com> <20190115170741.GB27730@localhost.localdomain>
In-Reply-To: <20190115170741.GB27730@localhost.localdomain>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Tue, 15 Jan 2019 19:36:03 +0100
Message-ID: <CAJZ5v0iZ_i9vOPJgn69T=f8KE=fFm1vQt2AuEaNDGpn3E_cL3g@mail.gmail.com>
Subject: Re: [PATCHv3 03/13] acpi/hmat: Parse and report heterogeneous memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>

On Tue, Jan 15, 2019 at 6:09 PM Keith Busch <keith.busch@intel.com> wrote:
>
> On Thu, Jan 10, 2019 at 07:42:46AM -0800, Rafael J. Wysocki wrote:
> > On Wed, Jan 9, 2019 at 6:47 PM Keith Busch <keith.busch@intel.com> wrote:
> > >
> > > Systems may provide different memory types and export this information
> > > in the ACPI Heterogeneous Memory Attribute Table (HMAT). Parse these
> > > tables provided by the platform and report the memory access and caching
> > > attributes.
> > >
> > > Signed-off-by: Keith Busch <keith.busch@intel.com>
> >
> > While this is generally fine by me, it's another piece of code going
> > under drivers/acpi/ just because it happens to use ACPI to extract
> > some information from the platform firmware.
> >
> > Isn't there any better place for it?
>
> I've tried to abstract the user visible parts outside any particular
> firmware implementation, but HMAT parsing is an ACPI specific feature,
> so I thought ACPI was a good home for this part. I'm open to suggestions
> if there's a better place. Either under in another existing subsystem,
> or create a new one under drivers/hmat/?

Well, there is drivers/acpi/nfit for the NVDIMM-related things, so
maybe there could be drivers/acpi/mm/ containing nfit/ and hmat.c (and
maybe some other mm-related things)?
