Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id A27166B0038
	for <linux-mm@kvack.org>; Fri,  5 May 2017 03:49:32 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id z29so10380633uab.0
        for <linux-mm@kvack.org>; Fri, 05 May 2017 00:49:32 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id j5si2349099uab.67.2017.05.05.00.49.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 May 2017 00:49:30 -0700 (PDT)
Message-ID: <1493970557.25766.385.camel@kernel.crashing.org>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 05 May 2017 09:49:17 +0200
In-Reply-To: <ac379467-0f9b-bbb2-955e-e677d94200f1@intel.com>
References: <20170419075242.29929-1-bsingharora@gmail.com>
	 <20170502143608.GM14593@dhcp22.suse.cz> <1493875615.7934.1.camel@gmail.com>
	 <20170504125250.GH31540@dhcp22.suse.cz>
	 <1493912961.25766.379.camel@kernel.crashing.org>
	 <ac379467-0f9b-bbb2-955e-e677d94200f1@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>, Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On Thu, 2017-05-04 at 10:33 -0700, Dave Hansen wrote:
> > However the TLB invalidations are quite expensive with a GPU so too
> > much harvesting is detrimental, and the GPU tends to check pages out
> > using a special "read with intend to write" mode, which means it almost
> > always set the dirty bit if the page is writable to begin with.
> 
> Why do you have to invalidate the TLB?A  Does the GPU have a TLB so large
> that it can keep thing in the TLB for super-long periods of time?
> 
> We don't flush the TLB on clearing Accessed on x86 normally.

We don't *have* to but there is no telling when it will get set again.

I always found the non-invalidation of the TLB for harvesting
"Accessed" on x86 chancy ... if a process pounds on a handful of pages
heavily, they never get seen as accessed, which is just plain weird.

But yes, we can do the same thing.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
