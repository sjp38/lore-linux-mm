Date: Thu, 30 Sep 2004 07:49:56 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: slab fragmentation ?
Message-ID: <29460000.1096555795@[10.10.2.4]>
In-Reply-To: <20040929204143.134154bc.akpm@osdl.org>
References: <1096500963.12861.21.camel@dyn318077bld.beaverton.ibm.com> <20040929204143.134154bc.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Badari Pulavarty <pbadari@us.ibm.com>
Cc: manfred@colorfullife.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Andrew Morton <akpm@osdl.org> wrote (on Wednesday, September 29, 2004 20:41:43 -0700):

> Badari Pulavarty <pbadari@us.ibm.com> wrote:
>> 
>> # name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <batchcount> <limit> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
>> size-40             2633  11468     64   61    1 : tunables  120   60    8 : slabdata    188    188      0
>> size-40             2633  11468     64   61    1 : tunables  120   60    8 : slabdata    188    188      0
>> size-40             2633  11468     64   61    1 : tunables  120   60    8 : slabdata    188    188      0
>> size-40             2633  11468     64   61    1 : tunables  120   60    8 : slabdata    188    188      0
>> size-40             4457  27084     64   61    1 : tunables  120   60    8 : slabdata    444    444      0
>> size-40             7685  59292     64   61    1 : tunables  120   60    8 : slabdata    972    972      0
>> size-40            10761  89548     64   61    1 : tunables  120   60    8 : slabdata   1468   1468      0
>> size-40            13589 119316     64   61    1 : tunables  120   60    8 : slabdata   1956   1956      0
>> size-40            16717 149084     64   61    1 : tunables  120   60    8 : slabdata   2444   2444      0
> 
> That looks like plain brokenness rather than fragmentation.  We shouldn't
> be allocating new pages until active_objs reaches num_objs, should we?
> 
> Unless the accouting is broken, or course...

Doesn't this happen if we allocate 1000 slabs, then free half the elements
in each of the slabs? Which seemed to be the default action of the slab 
shrink routines ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
