Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1982F6B0038
	for <linux-mm@kvack.org>; Fri,  5 May 2017 13:59:22 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id z29so4719084uab.0
        for <linux-mm@kvack.org>; Fri, 05 May 2017 10:59:22 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id m186si2581698vkb.16.2017.05.05.10.59.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 May 2017 10:59:19 -0700 (PDT)
Message-ID: <1494007148.25766.408.camel@kernel.crashing.org>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 05 May 2017 19:59:08 +0200
In-Reply-To: <20170505174851.GA6534@redhat.com>
References: <20170419075242.29929-1-bsingharora@gmail.com>
	 <20170502143608.GM14593@dhcp22.suse.cz> <1493875615.7934.1.camel@gmail.com>
	 <20170504125250.GH31540@dhcp22.suse.cz>
	 <1493912961.25766.379.camel@kernel.crashing.org>
	 <20170505145238.GE31461@dhcp22.suse.cz>
	 <1493999822.25766.397.camel@kernel.crashing.org>
	 <20170505174851.GA6534@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On Fri, 2017-05-05 at 13:48 -0400, Jerome Glisse wrote:
> Well there is _no_ migration issues with HMM (anonymous or file back
> pages). What you don't get is thing like lru or numa balancing but i
> believe you do not want either of those anyway.

We don't want them in the specific case of GPUs today for various
reasons related more to how they are used and specific implementation
shortcomings, so matter of policy.

However, I don't think they are necessarily to be excluded in the grand
scheme of things of coherent accelerators with local memory.

So my gut feeling (but we can agree to disagree, in the end, what we
need is *a* workable solution to enable these things, which ever it is
that wins), is that we are better off simply treating them as normal
numa nodes, and adding more policy tunables where needed, if possible
with some of these being set to reasonable defaults by the driver
itself to account for implementation shortcomings.

Now, if Michal and Mel strongly prefer the approach based on HMM, we
can make it work as well I believe. It feels less "natural" and more
convoluted. That's it.

This is by no mean a criticism of HMM btw :-) HMM still is a critical
part of getting the non-coherent devices working properly, and which
ever representation we use for the memory on the coherent ones, we will
also use parts of HMM infrastructure for driver directed migration
anyway.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
