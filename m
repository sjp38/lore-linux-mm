Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 680996B705F
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 14:41:55 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id r13so6124770ioj.9
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 11:41:55 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id l26si4181123iok.122.2018.12.04.11.41.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 11:41:54 -0800 (PST)
References: <20181203233509.20671-1-jglisse@redhat.com>
 <20181203233509.20671-3-jglisse@redhat.com> <875zw98bm4.fsf@linux.intel.com>
 <20181204182421.GC2937@redhat.com>
 <CAPcyv4gtv7eUc1_3Yhz-f-B3Lct=Vq7zqUJKOqCtWYb4BS6i9g@mail.gmail.com>
 <20181204185725.GE2937@redhat.com>
 <de7c1099-2717-6396-bf56-c4ab4085ee83@deltatee.com>
 <20181204192221.GG2937@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <f759cc28-309d-930c-da7d-34144a4d5517@deltatee.com>
Date: Tue, 4 Dec 2018 12:41:39 -0700
MIME-Version: 1.0
In-Reply-To: <20181204192221.GG2937@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com



On 2018-12-04 12:22 p.m., Jerome Glisse wrote:
> So version is a bad prefix, what about type, prefixing target with a
> type id. So that application that are looking for a certain type of
> memory (which has a set of define properties) can select them. Having
> a type file inside the directory and hopping application will read
> that sysfs file is a recipies for failure from my point of view. While
> having it in the directory name is making sure that the application
> has some idea of what it is doing.

Well I don't think it can be a prefix. It has to be a mask. It might be
things like cache coherency, persistence, bandwidth and none of those
things are mutually exclusive.

>> Also, in the same vein, I think it's wrong to have the API enumerate all
>> the different memory available in the system. The API should simply
>> allow userspace to say it wants memory that can be accessed by a set of
>> initiators with a certain set of attributes and the bind call tries to
>> fulfill that or fallback on system memory/hmm migration/whatever.
> 
> We have existing application that use topology today to partition their
> workload and do load balancing. Those application leverage the fact that
> they are only running on a small set of known platform with known topology
> here i want to provide a common API so that topology can be queried in a
> standard by application.

Existing applications are not a valid excuse for poor API design.
Remember, once this API is introduced and has real users, it has to be
maintained *forever*, so we need to get it right. Providing users with
more information than they need makes it exponentially harder to get
right and support.

Logan
