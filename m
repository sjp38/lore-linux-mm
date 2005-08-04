Date: Fri, 5 Aug 2005 00:54:13 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: Getting rid of SHMMAX/SHMALL ?
Message-ID: <20050804225413.GH8266@wotan.suse.de>
References: <20050804132338.GT8266@wotan.suse.de> <200508042249.j74Mndg18582@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200508042249.j74Mndg18582@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Andi Kleen' <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, Anton Blanchard <anton@samba.org>, cr@sap.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 04, 2005 at 03:49:37PM -0700, Chen, Kenneth W wrote:
> Andi Kleen wrote on Thursday, August 04, 2005 6:24 AM
> > I think we should just get rid of the per process limit and keep
> > the global limit, but make it auto tuning based on available memory.
> > That is still not very nice because that would likely keep it < available 
> > memory/2, but I suspect databases usually want more than that. So
> > I would even make it bigger than tmpfs for reasonably big machines.
> > Let's say
> > 
> > if (main memory >= 1GB)
> > 	maxmem = main memory - main memory/8 
> 
> This might be too low on large system.  We usually stress shm pretty hard
> for db application and usually use more than 87% of total memory in just
> one shm segment.  So I prefer either no limit or a tunable.

With large system you mean >32GB right?

I think on a large systems some tuning is reasonable because they likely
have trained admins. I'm more worried on reasonable defaults for the
class of systems with 0-4GB

The /8 was to account for the overhead of page tables and mem_map and
leave some other memory for the system, but you're right it might be less 
with hugetlbfs.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
