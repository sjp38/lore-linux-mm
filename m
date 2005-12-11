Date: Sun, 11 Dec 2005 16:32:41 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [RFC 3/6] Make nr_pagecache a per zone counter
Message-ID: <20051211183241.GD4267@dmt.cnet>
References: <20051210005440.3887.34478.sendpatchset@schroedinger.engr.sgi.com> <20051210005456.3887.94412.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051210005456.3887.94412.sendpatchset@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 09, 2005 at 04:54:56PM -0800, Christoph Lameter wrote:
> Make nr_pagecache a per node variable
> 
> Currently a single atomic variable is used to establish the size of the page cache
> in the whole machine. The zoned VM counters have the same method of implementation
> as the nr_pagecache code. Remove the special implementation for nr_pagecache and make
> it a zoned counter. We will then be able to figure out how much of the memory in a
> zone is used by the pagecache.
> 
> Updates of the page cache counters are always performed with interrupts off.
> We can therefore use the __ variant here.

By the way, why does nr_pagecache needs to be an atomic variable on UP systems?

#ifdef CONFIG_SMP
...
#else

static inline void pagecache_acct(int count)
{
        atomic_add(count, &nr_pagecache);
}
#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
