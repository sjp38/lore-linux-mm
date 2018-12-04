Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id B3D546B7090
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 15:30:23 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id p66so13976258itc.0
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 12:30:23 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id m16si6907340iti.105.2018.12.04.12.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 12:30:22 -0800 (PST)
References: <20181203233509.20671-1-jglisse@redhat.com>
 <20181203233509.20671-3-jglisse@redhat.com> <875zw98bm4.fsf@linux.intel.com>
 <20181204182421.GC2937@redhat.com>
 <CAPcyv4gtv7eUc1_3Yhz-f-B3Lct=Vq7zqUJKOqCtWYb4BS6i9g@mail.gmail.com>
 <20181204185725.GE2937@redhat.com>
 <de7c1099-2717-6396-bf56-c4ab4085ee83@deltatee.com>
 <20181204192221.GG2937@redhat.com>
 <f759cc28-309d-930c-da7d-34144a4d5517@deltatee.com>
 <20181204201347.GK2937@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <2f146730-1bf9-db75-911d-67809fc7afef@deltatee.com>
Date: Tue, 4 Dec 2018 13:30:01 -0700
MIME-Version: 1.0
In-Reply-To: <20181204201347.GK2937@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com



On 2018-12-04 1:13 p.m., Jerome Glisse wrote:
> You are right many are non exclusive. It is just my feeling that having
> a mask as a file inside the target directory might be overlook by the
> application which might start using things it should not. At same time
> i guess if i write the userspace library that abstract this kernel API
> then i can enforce application to properly select thing.

I think this is just evidence that this is not a good API. If the user
has the option to just ignore things or do it wrong that's a problem
with the API. Using a prefix for the name doesn't change that fact.

> I do not think there is a way to answer that question. I am siding on the
> side of this API can be dumb down in userspace by a common library. So let
> expose the topology and let userspace dumb it down.

I fundamentally disagree with this approach to designing APIs. Saying
"we'll give you the kitchen sink, add another layer to deal with the
complexity" is actually just eschewing API design and makes it harder
for kernel folks to know what userspace actually requires because they
are multiple layers away.

> If we dumb it down in the kernel i see few pitfalls:
>     - kernel dumbing it down badly
>     - kernel dumbing down code can grow out of control with gotcha
>       for platform

This is just a matter of designing the APIs well. Don't do it badly.

>     - it is still harder to fix kernel than userspace in commercial
>       user space (the whole RHEL business of slow moving and long
>       supported kernel). So on those being able to fix thing in
>       userspace sounds pretty enticing

I hear this argument a lot and it's not compelling to me. I don't think
we should make decisions in upstream code to allow RHEL to bypass the
kernel simply because it would be easier for them to distribute code
changes.

Logan
