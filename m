Date: Mon, 14 Oct 2002 18:08:59 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [Lse-tech] Re: [rfc][patch] Memory Binding API v0.3 2.5.41
Message-ID: <20021015010859.GM4488@holomorphy.com>
References: <3DAB5DF2.5000002@us.ibm.com> <2004595005.1034616026@[10.10.2.3]> <3DAB6385.9000207@us.ibm.com> <1034643354.19094.149.camel@cog>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1034643354.19094.149.camel@cog>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: john stultz <johnstul@us.ibm.com>
Cc: Matt <colpatch@us.ibm.com>, "Martin J. Bligh" <mbligh@aracnet.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, LSE Tech <lse-tech@lists.sourceforge.net>, Andrew Morton <akpm@zip.com.au>, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2002-10-14 at 17:38, Matthew Dobson wrote:
>> Also, right now, memblks map to nodes in a straightforward manner (1-1 
>> on NUMA-Q, the only architecture that has defined them).  It will likely 
>> look the same on most architectures, too.

On Mon, Oct 14, 2002 at 05:55:53PM -0700, john stultz wrote:
> Just an FYI: I believe the x440 breaks this assumption. 
> There are 2 chunks on the first CEC. The current discontig patch for it
> has to drop the second chunk (anything over 3.5G on the first CEC) in
> order to work w/ the existing code. However, that will probably need to
> be addressed at some point, so be aware that this might affect you as
> well. 

MAP_NR_DENSE()-based zone-relative pfn to zone->zone_mem_map index
remapping is designed to handle this (and actually more severe
situations). The only constraint is that pfn's must be monotonically
increasing with ->zone_mem_map index. Some non-i386 architectures
virtually remap physical memory to provide the illusion of contiguity
of kernel virtual memory, but in a mature port (e.g. i386) there's high
risk of breaking numerous preexisting drivers.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
