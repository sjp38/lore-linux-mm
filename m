Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 207E56B02E1
	for <linux-mm@kvack.org>; Mon,  1 May 2017 21:29:19 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 194so66899757iof.21
        for <linux-mm@kvack.org>; Mon, 01 May 2017 18:29:19 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id 126si386338ity.6.2017.05.01.18.29.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 18:29:18 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id t7so18473658pgt.1
        for <linux-mm@kvack.org>; Mon, 01 May 2017 18:29:17 -0700 (PDT)
Message-ID: <1493688548.15044.1.camel@gmail.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 02 May 2017 11:29:08 +1000
In-Reply-To: <91272c14-81df-9529-f0ae-6abb17a694ea@nvidia.com>
References: <20170419075242.29929-1-bsingharora@gmail.com>
	 <91272c14-81df-9529-f0ae-6abb17a694ea@nvidia.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On Mon, 2017-05-01 at 13:41 -0700, John Hubbard wrote:
> On 04/19/2017 12:52 AM, Balbir Singh wrote:
> > This is a request for comments on the discussed approaches
> > for coherent memory at mm-summit (some of the details are at
> > https://lwn.net/Articles/717601/). The latest posted patch
> > series is at https://lwn.net/Articles/713035/. I am reposting
> > this as RFC, Michal Hocko suggested using HMM for CDM, but
> > we believe there are stronger reasons to use the NUMA approach.
> > The earlier patches for Coherent Device memory were implemented
> > and designed by Anshuman Khandual.
> > 
> 
> Hi Balbir,
> 
> Although I think everyone agrees that in the [very] long term, these 
> hardware-coherent nodes probably want to be NUMA nodes, in order to decide what to 
> code up over the next few years, we need to get a clear idea of what has to be done 
> for each possible approach.
> 
> Here, the CDM discussion is falling just a bit short, because it does not yet 
> include the whole story of what we would need to do. Earlier threads pointed this 
> out: the idea started as a large patchset RFC, but then, "for ease of review", it 
> got turned into a smaller RFC, which loses too much context.

Hi, John

I thought I explained the context, but I'll try again. I see the whole solution
as a composite of the following primitives:

1. Enable hotplug of CDM nodes
2. Isolation of CDM memory
3. Migration to/from CDM memory
4. Performance enhancements for migration

The RFC here is for (2) above. (3) is handled by HMM and (4) is being discussed
in the community. I think the larger goals are same as HMM, except that we
don't need unaddressable memory, since the memory is cache coherent.

> 
> So, I'd suggest putting together something more complete, so that it can be fairly 
> compared against the HMM-for-hardware-coherent-nodes approach.
>

Since I intend to reuse bits of HMM, I am not sure if I want to repost those
patches as a part of my RFC. I hope my answers make sense, the goal is to
reuse as much of what is available. From a user perspective

1. We see no new interface being added in either case, the programming model
would differ though
2. We expect the programming model to be abstracted behind a user space
framework, potentially like CUDA or CXL

 
> 
> > Jerome posted HMM-CDM at https://lwn.net/Articles/713035/.
> > The patches do a great deal to enable CDM with HMM, but we
> > still believe that HMM with CDM is not a natural way to
> > represent coherent device memory and the mm will need
> > to be audited and enhanced for it to even work.
> 
> That is also true for the CDM approach. Specifically, in order for this to be of any 
> use to device drivers, we'll need the following:
>

Since Reza answered these questions, I'll skip them in this email

Thanks for the review!
Balbir Singh 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
