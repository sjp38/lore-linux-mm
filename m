Date: Thu, 29 Sep 2005 18:32:50 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: [PATCH] earlier allocation of order 0 pages from pcp in	__alloc_pages
Message-ID: <729020000.1128043969@[10.10.2.4]>
In-Reply-To: <1128043933.3735.26.camel@akash.sc.intel.com>
References: <20050929150155.A15646@unix-os.sc.intel.com> <719460000.1128034108@[10.10.2.4]> <1128043933.3735.26.camel@akash.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rohit Seth <rohit.seth@intel.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> I will update/streamline __alloc_pages code and send the patch.
> 
>> It looks like we're now dropping into direct reclaim as the first thing
>> in __alloc_pages before even trying to kick off kswapd. When the hell
>> did that start? Or is that only meant to trigger if we're already below
>> the low watermark level?
>> 
> 
> As Andrew said in the other mail that do_reclaim is never true so the
> first reclaim never happens.  That also means that we don't look at pcp
> for the scenarios when zone has run below the low water mark before
> waking kswapd.
> 
>> What do we want to do at a higher level?
>> 
>> 	if (order 0) and (have stuff in the local lists)
>> 		take from local lists
>> 	else if (we're under a little pressure)
>> 		do kswapd reclaim
>> 	else if (we're under a lot of pressure)
>> 		do direct reclaim?
>> 
>> That whole code area seems to have been turned into spagetti, without
>> any clear comments.
> 
> Agreed. 

Thanks. I didn't mean you'd done so, BTW ... just many iterations of people
stacking more and more stuff on top without it ever getting cleaned up,
and it's got a bit silly ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
