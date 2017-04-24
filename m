Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E99D6B02F2
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 10:00:42 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id a103so191624582ioj.8
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 07:00:42 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id f15si20266207iod.240.2017.04.24.07.00.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 07:00:41 -0700 (PDT)
Date: Mon, 24 Apr 2017 09:00:39 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
In-Reply-To: <1492993241.2418.2.camel@gmail.com>
Message-ID: <alpine.DEB.2.20.1704240858410.15223@east.gentwo.org>
References: <20170419075242.29929-1-bsingharora@gmail.com> <alpine.DEB.2.20.1704191355280.9478@east.gentwo.org> <1492651508.1015.2.camel@gmail.com> <alpine.DEB.2.20.1704201025360.26403@east.gentwo.org> <1492993241.2418.2.camel@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz

On Mon, 24 Apr 2017, Balbir Singh wrote:

> > cgroups, memory policy and cpuset provide that
> >
>
> Yes and we are building on top of mempolicies. The problem becomes a little
> worse when the coherent device memory node is seen as CPUless node. I
> was trying to solve 1 and 2 with the same approach.

Well I think having the ability to restrict autonuma/ksm per node may also
be useful for other things. Like running regular processes on node 0 and
running low latency stuff on  node 1 that should not be interrupted. Right
now you cannot do that.

> > > 2. Isolation of certain algorithms like kswapd/auto-numa balancing
> >
> > Ok that may mean adding some generic functionality to limit those
>
> As in per-algorithm tunables? I think it would be definitely good to have
> that. I do not know how well that would scale?

>From what I can see it should not be too difficult to implement a node
mask constraining those activities.

> Some of these requirements come from whether we use NUMA or HMM-CDM.
> We prefer NUMA and it meets the above requirements quite well.

Great.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
