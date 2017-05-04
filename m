Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id B9CB36B02C4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 11:49:48 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id 5so72538vkj.7
        for <linux-mm@kvack.org>; Thu, 04 May 2017 08:49:48 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id y64si1151701vkc.128.2017.05.04.08.49.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 May 2017 08:49:47 -0700 (PDT)
Message-ID: <1493912961.25766.379.camel@kernel.crashing.org>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 04 May 2017 17:49:21 +0200
In-Reply-To: <20170504125250.GH31540@dhcp22.suse.cz>
References: <20170419075242.29929-1-bsingharora@gmail.com>
	 <20170502143608.GM14593@dhcp22.suse.cz> <1493875615.7934.1.camel@gmail.com>
	 <20170504125250.GH31540@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On Thu, 2017-05-04 at 14:52 +0200, Michal Hocko wrote:
> But the direct reclaim would be effective only _after_ all other nodes
> are full.
> 
> I thought that kswapd reclaim is a problem because the HW doesn't
> support aging properly but as the direct reclaim works then what is the
> actual problem?

Ageing isn't isn't completely broken. The ATS MMU supports
dirty/accessed just fine.

However the TLB invalidations are quite expensive with a GPU so too
much harvesting is detrimental, and the GPU tends to check pages out
using a special "read with intend to write" mode, which means it almost
always set the dirty bit if the page is writable to begin with.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
