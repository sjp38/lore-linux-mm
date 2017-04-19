Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A512B6B0390
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 15:03:10 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id v34so28415150iov.22
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 12:03:10 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id l186si16044138itd.93.2017.04.19.12.02.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 12:02:51 -0700 (PDT)
Date: Wed, 19 Apr 2017 14:02:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
In-Reply-To: <20170419075242.29929-1-bsingharora@gmail.com>
Message-ID: <alpine.DEB.2.20.1704191355280.9478@east.gentwo.org>
References: <20170419075242.29929-1-bsingharora@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz

On Wed, 19 Apr 2017, Balbir Singh wrote:

> The first patch defines N_COHERENT_MEMORY and supports onlining of
> N_COHERENT_MEMORY.  The second one enables marking of coherent

The name is confusing. All other NUMA nodes are coherent. Can we name this
in some way that describes what is special about these nodes?

And we already have support for memory only nodes. Why is that not sufficient?
If you can answer that question then we may get to the term to be used to
name these nodes. We also have support for hotplug memory. How does the
memory here differ from hotplug?

 > memory nodes in architecture specific code, the third patch
> enables mempolicy MPOL_BIND and MPOL_PREFERRED changes to
> explicitly specify a node for allocation. The fourth patch adds

Huh? MPOL_PREFERRED already allows specifying a node.
MPOL_BIND requires a set of nodes. ??

> 1. Nodes with N_COHERENT_MEMORY don't have CPUs on them, so
> effectively they are CPUless memory nodes
> 2. Nodes with N_COHERENT_MEMORY are marked as movable_nodes.
> Slub allocations from these nodes will fail otherwise.

Isnt that what hotpluggable nodes do already?

> 1. MPOL_BIND with the coherent node (Node 3 in the above example) will
> not filter out N_COHERENT_MEMORY if any of the nodes in the nodemask
> is in N_COHERENT_MEMORY
> 2. MPOL_PREFERRED will use the FALLBACK list of the coherent node (Node 3)
> if a policy that specifies a preference to it is used.

So this means that "Coherent" nodes means that you need a different
fallback mechanism? Something like a ISOLATED_NODE or something?

The approach sounds pretty invasive to me. Can we first clarify what
features you need and develop terminology that describes things in terms
of a view from the Linux MM perspective? Coherent memory is nothing
special from there. It is special from the perspective of offload devices
that have heretofore not offered that. So its mainly a marketing term. We
need something descriptive here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
