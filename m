Message-ID: <421283E6.9030707@sgi.com>
Date: Tue, 15 Feb 2005 17:21:10 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration -- sys_page_migrate
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>	<20050212032620.18524.15178.29731@tomahawk.engr.sgi.com>	<1108242262.6154.39.camel@localhost>	<20050214135221.GA20511@lnx-holt.americas.sgi.com>	<1108407043.6154.49.camel@localhost>	<20050214220148.GA11832@lnx-holt.americas.sgi.com>	<20050215074906.01439d4e.pj@sgi.com>	<20050215162135.GA22646@lnx-holt.americas.sgi.com>	<20050215083529.2f80c294.pj@sgi.com>	<20050215185943.GA24401@lnx-holt.americas.sgi.com> <16914.28795.316835.291470@wombat.chubb.wattle.id.au>
In-Reply-To: <16914.28795.316835.291470@wombat.chubb.wattle.id.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: raybry@austin.rr.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Peter Chubb wrote:

> 
> A possibly stupid suggestion: 
> 
> Can page migration be done lazily, instead of all at once?  Move the
> process, mark its pages as candidates for migration, and when 
> the page faults, decide whether to copy across or not...
> 
> That way you only copy the pages the process is using, and only copy
> each page once.  It makes copy for replication easier in some future
> incarnation, too, because the same basic infrastructure can be used.
>

I think that part of the motivation here (e. g. the batch scheduler on
a  large NUMA machine) is to push pages off of the old nodes so that
a new job running on the old nodes can allocate memory quickly and
efficiently (i. e. without having to swap out the old job's pages).

True enough, we may move pages that are not currently being used.
But. on our large NUMA systems, we want the nodes where a new job
starts to be relatively clean so that local page allocations are
indeed satisfied by local pages and that these requests do not
spill off node.

> --
> Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
> The technical we do immediately,  the political takes *forever*
> 


-- 
-----------------------------------------------
Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
	 so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
