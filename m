Subject: Re: slab fragmentation ?
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <41617567.9010507@colorfullife.com>
References: <1096500963.12861.21.camel@dyn318077bld.beaverton.ibm.com>
	 <20040929204143.134154bc.akpm@osdl.org>  <29460000.1096555795@[10.10.2.4]>
	 <1096555693.12861.27.camel@dyn318077bld.beaverton.ibm.com>
	 <415F968B.8000403@colorfullife.com>
	 <1096905099.12861.117.camel@dyn318077bld.beaverton.ibm.com>
	 <41617567.9010507@colorfullife.com>
Content-Type: text/plain
Message-Id: <1096911467.12861.119.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 04 Oct 2004 10:37:48 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2004-10-04 at 09:08, Manfred Spraul wrote:
> Badari Pulavarty wrote:
> 
> >I will enable slab debugging. Someone told me that, by enabling slab
> >debug, it fill force use of different slab for each allocation - there
> >by bloating slab usages and mask the problem. Is it true ?
> >
> >  
> >
> Then set STATS to 1. It's around line 118. This just adds full 
> statistics without changing the allocations.
> Or even better: enable STATS and DEBUG, but not FORCED_DEBUG. You get 
> most internal consistance checks as well, except the tests that rely on 
> redzoning.

Sure. Will do and get back to you end of day. I am in all day class :(

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
