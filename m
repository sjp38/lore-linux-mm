Message-ID: <3DA5CA56.6070402@us.ibm.com>
Date: Thu, 10 Oct 2002 11:43:34 -0700
From: Matthew Dobson <colpatch@us.ibm.com>
Reply-To: colpatch@us.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch] Memory Binding API v0.3 2.5.41
References: <3DA4D3E4.6080401@us.ibm.com> <1586204621.1034197575@[10.10.2.3]>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, LSE <lse-tech@lists.sourceforge.net>, Andrew Morton <akpm@zip.com.au>, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:
>>+#define for_each_valid_zone(zone, zonelist) 		\
>>+	for (zone = *zonelist->zones; zone; zone++)	\
>>+		if (current->memblk_binding.bitmask & (1 << zone->zone_pgdat->memblk_id))
> 
> Does the compiler optimise the last bit away on non-NUMA?
Nope.

> Want to wrap it in #ifdef CONFIG_NUMA_MEMBIND or something?
Not a problem...  I've got some free time this afternoon...  Should only 
take me a few hours to retool the patch to include this change.  ;)

> Not sure what the speed impact of this would be, but I'd
> rather it was optional, even on NUMA boxen.
Sounds reasonable...  It'll be in the next itteration.

> Other than that, looks pretty good.
Glad to hear!

> M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
