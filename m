Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 59E0C8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 11:25:31 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id m52so6347714otc.13
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 08:25:31 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 38sor47092982otb.40.2019.01.11.08.25.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 08:25:29 -0800 (PST)
MIME-Version: 1.0
References: <20190109174341.19818-1-keith.busch@intel.com> <20190109174341.19818-8-keith.busch@intel.com>
 <87y37sit8x.fsf@linux.ibm.com> <20190110173016.GC21095@localhost.localdomain>
 <20190111113238.000068b0@huawei.com> <20190111155828.GD21095@localhost.localdomain>
In-Reply-To: <20190111155828.GD21095@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 11 Jan 2019 08:25:17 -0800
Message-ID: <CAPcyv4iHxyQkCScMzDM3YyuP6+zhqvNXtYHg_rdhgrOq9tevbg@mail.gmail.com>
Subject: Re: [PATCHv3 07/13] node: Add heterogenous memory access attributes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: Jonathan Cameron <jonathan.cameron@huawei.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Fri, Jan 11, 2019 at 7:59 AM Keith Busch <keith.busch@intel.com> wrote:
>
> On Fri, Jan 11, 2019 at 11:32:38AM +0000, Jonathan Cameron wrote:
> > On Thu, 10 Jan 2019 10:30:17 -0700
> > Keith Busch <keith.busch@intel.com> wrote:
> > > I am not aware of a real platform that has an initiator-target pair with
> > > better latency but worse bandwidth than any different initiator paired to
> > > the same target. If such a thing exists and a subsystem wants to report
> > > that, you can register any arbitrary number of groups or classes and
> > > rank them according to how you want them presented.
> > >
> >
> > It's certainly possible if you are trading off against pin count by going
> > out of the soc on a serial bus for some large SCM pool and also have a local
> > SCM pool on a ddr 'like' bus or just ddr on fairly small number of channels
> > (because some one didn't put memory on all of them).
> > We will see this fairly soon in production parts.
> >
> > So need an 'ordering' choice for this circumstance that is predictable.
>
> As long as the reported memory target access attributes are accurate for
> the initiator nodes listed under an access class, I'm not sure that it
> matters what order you use. All the information needed to make a choice
> on which pair to use is available, and the order is just an implementation
> specific decision.

Agree with Keith. If the performance is differentiated it will be in a
separate class. A hierarchy of classes is not enforced by the
interface, but it tries to advertise some semblance of the "best"
initiator pairing for a given target by default with the flexibility
to go more complex if the situation arises.

As was seen in the SCSI specification efforts to advertise all manner
of cache hinting the kernel community discovered that only a small
fraction of what hardware vendors thought mattered actually
demonstrated value in practice. That experience is instructive that
the kernel interfaces for hardware performance hints should prioritize
what makes sense for the kernel and applications generally, not
necessarily every conceivable performance detail that a hardware
platform chooses to expose, or niche applications might consume.
