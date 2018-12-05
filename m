Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F3A66B76DB
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 18:23:56 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id b21so9197153ioj.8
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 15:23:56 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id i186si7347575itc.87.2018.12.05.15.23.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Dec 2018 15:23:55 -0800 (PST)
References: <20181205023116.GD3045@redhat.com>
 <a5ae63ff-a913-25af-4648-4ebf91775412@deltatee.com>
 <20181205180756.GI3536@redhat.com>
 <e5c740fd-0256-8b70-cd06-6d6fee19806d@deltatee.com>
 <20181205183314.GJ3536@redhat.com>
 <0ddb2620-ecbd-4b7b-aeb7-3f4ae7746e83@deltatee.com>
 <20181205185550.GK3536@redhat.com>
 <7ab26ea6-d16d-8d71-78ca-4266a864f8d3@deltatee.com>
 <20181205225828.GL3536@redhat.com>
 <a0240f08-68ab-5167-c2c7-2f930aa0a54b@deltatee.com>
 <20181205232028.GO3536@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <af781c8a-1990-c091-0471-5b2d873ee526@deltatee.com>
Date: Wed, 5 Dec 2018 16:23:42 -0700
MIME-Version: 1.0
In-Reply-To: <20181205232028.GO3536@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com



On 2018-12-05 4:20 p.m., Jerome Glisse wrote:
> And my proposal is under /sys/bus and have symlink to all existing
> device it agregate in there.

That's so not the point. Use the existing buses don't invent some
virtual tree. I don't know how many times I have to say this or in how
many ways. I'm not responding anymore.

> So you agree with my proposal ? A sysfs directory in which all the
> bus and how they are connected to each other and what is connected
> to each of them (device, CPU, memory).

I'm fine with the motivation. What I'm arguing against is the
implementation and the fact you have to create a whole grand new
userspace API and hierarchy to accomplish it.

Logan
