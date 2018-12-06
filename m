Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 350C26B7709
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 19:09:02 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id n196so13327520oig.15
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 16:09:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t16sor11686181oth.4.2018.12.05.16.09.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 16:09:01 -0800 (PST)
MIME-Version: 1.0
References: <20181205180756.GI3536@redhat.com> <e5c740fd-0256-8b70-cd06-6d6fee19806d@deltatee.com>
 <20181205183314.GJ3536@redhat.com> <0ddb2620-ecbd-4b7b-aeb7-3f4ae7746e83@deltatee.com>
 <20181205185550.GK3536@redhat.com> <7ab26ea6-d16d-8d71-78ca-4266a864f8d3@deltatee.com>
 <20181205225828.GL3536@redhat.com> <a0240f08-68ab-5167-c2c7-2f930aa0a54b@deltatee.com>
 <20181205232028.GO3536@redhat.com> <af781c8a-1990-c091-0471-5b2d873ee526@deltatee.com>
 <20181205232710.GP3536@redhat.com>
In-Reply-To: <20181205232710.GP3536@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 5 Dec 2018 16:08:49 -0800
Message-ID: <CAPcyv4g2bb=GPErigvjWDdVn2vfLDawnr7-Q49TaJsD-6c-zMw@mail.gmail.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS) documentation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com

On Wed, Dec 5, 2018 at 3:27 PM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Wed, Dec 05, 2018 at 04:23:42PM -0700, Logan Gunthorpe wrote:
> >
> >
> > On 2018-12-05 4:20 p.m., Jerome Glisse wrote:
> > > And my proposal is under /sys/bus and have symlink to all existing
> > > device it agregate in there.
> >
> > That's so not the point. Use the existing buses don't invent some
> > virtual tree. I don't know how many times I have to say this or in how
> > many ways. I'm not responding anymore.
>
> And how do i express interaction with different buses because i just
> do not see how to do that in the existing scheme. It would be like
> teaching to each bus about all the other bus versus having each bus
> register itself under a common framework and have all the interaction
> between bus mediated through that common framework avoiding code
> duplication accross buses.
>
> >
> > > So you agree with my proposal ? A sysfs directory in which all the
> > > bus and how they are connected to each other and what is connected
> > > to each of them (device, CPU, memory).
> >
> > I'm fine with the motivation. What I'm arguing against is the
> > implementation and the fact you have to create a whole grand new
> > userspace API and hierarchy to accomplish it.

Right, GPUs show up in /sys today. Don't register a whole new
hierarchy as an alias to what already exists, add a new attribute
scheme to the existing hierarchy. This is what the HMAT enabling is
doing, this is what p2pdma is doing.
