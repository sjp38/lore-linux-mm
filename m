Date: Fri, 23 May 2008 07:25:46 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 08/18] hugetlb: multi hstate sysctls
Message-ID: <20080523052546.GH13071@wotan.suse.de>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.487393000@nick.local0.net> <20080425181430.GG9680@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080425181430.GG9680@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Fri, Apr 25, 2008 at 11:14:30AM -0700, Nishanth Aravamudan wrote:
> On 23.04.2008 [11:53:10 +1000], npiggin@suse.de wrote:
> > Expand the hugetlbfs sysctls to handle arrays for all hstates. This
> > now allows the removal of global_hstate -- everything is now hstate
> > aware.
> > 
> > - I didn't bother with hugetlb_shm_group and treat_as_movable,
> > these are still single global.
> > - Also improve error propagation for the sysctl handlers a bit
> 
> So, I may be mis-remembering, but the hugepages that are gigantic, that
> is > MAX_ORDER, cannot be allocated or freed at run-time? If so, why do

Right.

> we need to report them in the sysctl? It's a read-only value, right?

I guess for reporting and compatibility.


> Similarly, for the sysfs interface thereto, can I just make them
> read-only? I guess it would be an arbitrary difference from the other
> files, but reflects reality?

For the sysfs interface, I think that would be a fine idea to make
them readonly if they cannot be changed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
