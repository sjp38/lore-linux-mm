Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 88A4A6B709F
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 15:47:33 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id v8so18479582ioh.11
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 12:47:33 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id i8si9506000ioh.24.2018.12.04.12.47.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 12:47:32 -0800 (PST)
References: <20181203233509.20671-1-jglisse@redhat.com>
 <20181203233509.20671-3-jglisse@redhat.com> <875zw98bm4.fsf@linux.intel.com>
 <20181204182421.GC2937@redhat.com>
 <CAPcyv4gtv7eUc1_3Yhz-f-B3Lct=Vq7zqUJKOqCtWYb4BS6i9g@mail.gmail.com>
 <20181204185725.GE2937@redhat.com>
 <de7c1099-2717-6396-bf56-c4ab4085ee83@deltatee.com>
 <20181204201432.GH18167@tassilo.jf.intel.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <8ed92aba-a129-144f-34ab-f77102d54cfc@deltatee.com>
Date: Tue, 4 Dec 2018 13:47:17 -0700
MIME-Version: 1.0
In-Reply-To: <20181204201432.GH18167@tassilo.jf.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com



On 2018-12-04 1:14 p.m., Andi Kleen wrote:
>> Also, in the same vein, I think it's wrong to have the API enumerate all
>> the different memory available in the system. The API should simply

> We need an enumeration API too, just to display to the user what they
> have, and possibly for applications to size their buffers 
> (all we do with existing NUMA nodes)

Yes, but I think my main concern is the conflation of the enumeration
API and the binding API. An application doesn't want to walk through all
the possible memory and types in the system just to get some memory that
will work with a couple initiators (which it somehow has to map to
actual resources, like fds). We also don't want userspace to police
itself on which memory works with which initiator.

Enumeration is definitely not the common use case. And if we create a
new enumeration API now, it may make it difficult or impossible to unify
these types of memory with the existing NUMA node hierarchies if/when
this gets more integrated with the mm core.

Logan
