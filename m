Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 386558E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 11:54:58 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id b27so9852342otk.6
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 08:54:58 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 90sor9667285oti.17.2019.01.22.08.54.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 Jan 2019 08:54:57 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-6-keith.busch@intel.com>
 <CAJZ5v0jmkyrNBHzqHsOuWjLXF34tq83VnEhdBWrdFqxyiXC=cw@mail.gmail.com>
 <CAPcyv4gH0_e_NFJNOFH4XXarSs7+TOj4nT0r-D33ZGNCfqBdxg@mail.gmail.com>
 <20190119090129.GC10836@kroah.com> <CAJZ5v0jxuLPUvwr-hYstgC-7BKDwqkJpep94rnnUFvFhKG4W3g@mail.gmail.com>
 <20190122163650.GD1477@localhost.localdomain> <CAJZ5v0ggO9DePeYJkEoZ-ymB5VQywBgTnsGBo4WPHD5_JrjKRA@mail.gmail.com>
In-Reply-To: <CAJZ5v0ggO9DePeYJkEoZ-ymB5VQywBgTnsGBo4WPHD5_JrjKRA@mail.gmail.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Tue, 22 Jan 2019 17:54:45 +0100
Message-ID: <CAJZ5v0h1Q_dtJu7eXvs-7-bFRBBhLC158H1FKv96nE87rHv40A@mail.gmail.com>
Subject: Re: [PATCHv4 05/13] Documentation/ABI: Add new node sysfs attributes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Williams <dan.j.williams@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>

On Tue, Jan 22, 2019 at 5:51 PM Rafael J. Wysocki <rafael@kernel.org> wrote:
>
> On Tue, Jan 22, 2019 at 5:37 PM Keith Busch <keith.busch@intel.com> wrote:
> >
> > On Sun, Jan 20, 2019 at 05:16:05PM +0100, Rafael J. Wysocki wrote:
> > > On Sat, Jan 19, 2019 at 10:01 AM Greg Kroah-Hartman
> > > <gregkh@linuxfoundation.org> wrote:
> > > >
> > > > If you do a subdirectory "correctly" (i.e. a name for an attribute
> > > > group), that's fine.
> > >
> > > Yes, that's what I was thinking about: along the lines of the "power"
> > > group under device kobjects.
> >
> > We can't append symlinks to an attribute group, though.
>
> That's right, unfortunately.

Scratch this.

You can add them using sysfs_add_link_to_group().  For example, see
what acpi_power_expose_list() does.
