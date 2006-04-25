Message-ID: <444DF447.4020306@yahoo.com.au>
Date: Tue, 25 Apr 2006 20:04:55 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Page host virtual assist patches.
References: <20060424123412.GA15817@skybase>	 <20060424180138.52e54e5c.akpm@osdl.org>  <444DCD87.2030307@yahoo.com.au> <1145953914.5282.21.camel@localhost>
In-Reply-To: <1145953914.5282.21.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: schwidefsky@de.ibm.com
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky wrote:

> The point here is WHO does the reclaim. Sure we can do the reclaim in
> the guest but it is the host that has the memory pressure. To call into

By logic, if the host has memory pressure, and the guest is running on
the host, doesn't the guest have memory pressure? (Assuming you want to
reclaim guest pages, which you do because that is what your patches are
effectively doing anyway).

If the guest isn't under memory pressure (it has been allocated a fixed
amount of memory, and hasn't exceeded it), then you just don't call in.
Nor should you be employing this virtual assist reclaim on them.

> the guest is not a good idea, if you have an idle guest you generally
> increase the memory pressure because some of the guests pages might have
> been swapped which are needed if the guest has to do the reclaim. 

It might be a win in heavy swapping conditions to get your hypervisor's
tentacles into the guests' core VM, I could believe that. Doesn't mean
it is a good idea in our purpose OS.

How badly did the simple approach fare?

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
