Date: Mon, 11 Jul 2005 14:16:54 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [NUMA] /proc/<pid>/numa_maps to show on which nodes pages reside
In-Reply-To: <1121113875.15095.45.camel@localhost>
Message-ID: <Pine.LNX.4.62.0507111415420.23319@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0507081410520.16934@schroedinger.engr.sgi.com>
 <1121102433.15095.26.camel@localhost>  <Pine.LNX.4.62.0507111058270.21618@schroedinger.engr.sgi.com>
 <1121113875.15095.45.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, ia64 list <linux-ia64@vger.kernel.org>, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jul 2005, Dave Hansen wrote:

> Well, my point was that, if we have two, the numa_maps can be completely
> derived in userspace from the information in memory_maps plus sysfs
> alone.  So, why increase the kernel's complexity with two
> implementations that can do the exact same thing?  Yes, it might make
> the batch scheduler do one more pathname lookup, but that's not the
> kernel's problem :)
> 
> BTW, are you planning on using SPARSEMEM whenever NUMA is enabled in the
> future?  

I am not sure if we will be using SPARSEMEM or not. 

It would not be good to make the numa_maps patch depend on SPARSEMEM since
that is an optional feature right now.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
