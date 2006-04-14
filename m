Date: Fri, 14 Apr 2006 23:54:07 +0100 (IST)
From: Mel Gorman <mel@skynet.ie>
Subject: Re: [PATCH 0/7] [RFC] Sizing zones and holes in an architecture
 independent manner V2
In-Reply-To: <20060414205345.GA1258@agluck-lia64.sc.intel.com>
Message-ID: <Pine.LNX.4.64.0604142353460.22940@skynet.skynet.ie>
References: <20060412232036.18862.84118.sendpatchset@skynet>
 <20060413095207.GA4047@skynet.ie> <20060413171942.GA15047@agluck-lia64.sc.intel.com>
 <20060413173008.GA19402@skynet.ie> <20060413174720.GA15183@agluck-lia64.sc.intel.com>
 <20060413191402.GA20606@skynet.ie> <20060413215358.GA15957@agluck-lia64.sc.intel.com>
 <20060414131235.GA19064@skynet.ie> <20060414205345.GA1258@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: davej@codemonkey.org.uk, linuxppc-dev@ozlabs.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, bob.picco@hp.com, ak@suse.de, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 14 Apr 2006, Luck, Tony wrote:

> On Fri, Apr 14, 2006 at 02:12:35PM +0100, Mel Gorman wrote:
>> That appears fine, but I call add_active_range() after a GRANULEROUNDUP and
>> GRANULEROUNDDOWN has taken place so that might be the problem, especially as
>> all those ranges are aligned on a 16MiB boundary. The following patch calls
>> add_active_range() before the rounding takes place. Can you try it out please?
>
> That's good.  Now I see identical output before/after your patch for
> the generic (DISCONTIG=y) kernel:
>
> On node 0 totalpages: 259873
>  DMA zone: 128931 pages, LIFO batch:7
>  Normal zone: 130942 pages, LIFO batch:7
>

Very very cool. Thanks for all the testing.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
