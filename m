Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 39BB46B03BD
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 11:29:57 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j186so33006570oia.14
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 08:29:57 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id y8si3497118oie.271.2017.04.20.08.29.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 08:29:56 -0700 (PDT)
Date: Thu, 20 Apr 2017 10:29:52 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
In-Reply-To: <1492651508.1015.2.camel@gmail.com>
Message-ID: <alpine.DEB.2.20.1704201025360.26403@east.gentwo.org>
References: <20170419075242.29929-1-bsingharora@gmail.com> <alpine.DEB.2.20.1704191355280.9478@east.gentwo.org> <1492651508.1015.2.camel@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz

On Thu, 20 Apr 2017, Balbir Singh wrote:
> Couple of things are needed
>
> 1. Isolation of allocation

cgroups, memory policy and cpuset provide that

> 2. Isolation of certain algorithms like kswapd/auto-numa balancing

Ok that may mean adding some generic functionality to limit those

> > The approach sounds pretty invasive to me.
>
> Could you please elaborate, you mean the user space programming bits?

No I mean the modification of the memory policies in particular. We are
adding more exceptions to an already complex and fragile system.

Can we do this in a generic way just using hotplug nodes and some of the
existing isolation mechanisms?


> Ideally we need the following:
>
> 1. Transparency about being able to allocate memory anywhere and the ability
> to migrate memory between coherent device memory and normal system memory

If it is a memory node then you have that already.

> 2. The ability to explictly allocate memory from coherent device memory

Ditto

> 3. Isolation of normal allocations from coherent device memory unless
> explictly stated, same as (2) above

memory policies etc do that.

> 4. The ability to hotplug in and out the memory at run-time

hotplug code does that.


> 5. Exchange pointers between coherent device memory and normal memory
> for the compute on the coherent device memory to use

I dont see anything preventing that from occurring right now. Thats a
device issue with doing proper virtual to physical mapping right?

> I could list further things, but largely coherent device memory is like
> system memory except that we believe that things like auto-numa balancing
> and kswapd will not work well due to lack of information about references
> and faults.

Ok so far I do not see that we need coherent nodes at all.

> Some of the mm-summit notes are at https://lwn.net/Articles/717601/
> The goals align with HMM, except that the device memory is coherent. HMM
> has a CDM variation as well.

I was at the presentation but at that point you were interested in a
different approach it seems.

> We've been using the term coherent device memory (CDM). I could rephrase the
> text and documentation for consistency. Would you prefer a different term?

Hotplug memory node?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
