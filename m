Date: Wed, 09 Oct 2002 21:06:16 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [rfc][patch] Memory Binding API v0.3 2.5.41
Message-ID: <1586204621.1034197575@[10.10.2.3]>
In-Reply-To: <3DA4D3E4.6080401@us.ibm.com>
References: <3DA4D3E4.6080401@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: colpatch@us.ibm.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, LSE <lse-tech@lists.sourceforge.net>, Andrew Morton <akpm@zip.com.au>, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> +#define for_each_valid_zone(zone, zonelist) 		\
> +	for (zone = *zonelist->zones; zone; zone++)	\
> +		if (current->memblk_binding.bitmask & (1 << zone->zone_pgdat->memblk_id))

Does the compiler optimise the last bit away on non-NUMA?
Want to wrap it in #ifdef CONFIG_NUMA_MEMBIND or something?
Not sure what the speed impact of this would be, but I'd
rather it was optional, even on NUMA boxen.

Other than that, looks pretty good.

M.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
