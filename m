Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9BD6C8E00CD
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 05:40:31 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id i124so6115261pgc.2
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 02:40:31 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 62si3450284plc.87.2019.01.25.02.40.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 02:40:30 -0800 (PST)
Date: Fri, 25 Jan 2019 11:40:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] x86, numa: always initialize all possible nodes
Message-ID: <20190125104023.GI3560@dhcp22.suse.cz>
References: <20190114082416.30939-1-mhocko@kernel.org>
 <20190124141727.GN4087@dhcp22.suse.cz>
 <20190124175144.GF13790@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124175144.GF13790@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, Pingfan Liu <kernelfans@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu 24-01-19 19:51:44, Mike Rapoport wrote:
> On Thu, Jan 24, 2019 at 03:17:27PM +0100, Michal Hocko wrote:
> > a friendly ping for this. Does anybody see any problem with this
> > approach?
> 
> FWIW, it looks fine to me.
> 
> It'd just be nice to have a few more words in the changelog about *how* the
> x86 init was reworked ;-)

Heh, I thought it was there but nope... It probably just existed in my
head. Sorry about that. What about the following paragraphs added?
"
The new code relies on the arch specific initialization to allocate all
possible NUMA nodes (including memory less) - numa_register_memblks in
this case. Generic code then initializes both zonelists (__build_all_zonelists)
and allocator internals (free_area_init_nodes) for all non-null pgdats
rather than online ones.

For the x86 specific part also do not make new node online in alloc_node_data
because this is too early to know that. numa_register_memblks knows that
a node has some memory so it can make the node online appropriately.
init_memory_less_node hack can be safely removed altogether now.
"

-- 
Michal Hocko
SUSE Labs
