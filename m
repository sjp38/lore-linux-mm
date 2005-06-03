Date: Thu, 02 Jun 2005 22:37:12 -0700 (PDT)
Message-Id: <20050602.223712.41634750.davem@davemloft.net>
Subject: Re: Avoiding external fragmentation with a placement policy
 Version 12
From: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <357240000.1117776882@[10.10.2.4]>
References: <1117770488.5084.25.camel@npiggin-nld.site>
	<20050602.214927.59657656.davem@davemloft.net>
	<357240000.1117776882@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: "Martin J. Bligh" <mbligh@mbligh.org>
Date: Thu, 02 Jun 2005 22:34:42 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: mbligh@mbligh.org
Cc: nickpiggin@yahoo.com.au, jschopp@austin.ibm.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

> One of the calls I got the other day was for loopback interface. 
> Default MTU is 16K, which seems to screw everything up and do higher 
> order allocs. Turning it down to under 4K seemed to fix things. I'm 
> fairly sure loopback doesn't really need phys contig memory, but it 
> seems to use it at the moment ;-)

It helps get better bandwidth to have larger buffers.
That's why AF_UNIX tries to use larger orders as well.

With all these processors using prefetching in their
memcpy() implementations, reducing the number of memcpy()
calls per byte is getting more and more important.
Each memcpy() call makes you hit the memory latency
cost since the first prefetch can't be done early
enough.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
