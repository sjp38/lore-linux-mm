Message-ID: <41811C3B.2020700@kolumbus.fi>
Date: Thu, 28 Oct 2004 19:20:11 +0300
From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
MIME-Version: 1.0
Subject: Re: NUMA node swapping V3
References: <Pine.LNX.4.58.0410280820500.25586@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0410280820500.25586@schroedinger.engr.sgi.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 	if (pg == orig) {
> 		z->pageset[cpu].numa_hit++;
>+		/*
>+		 * If zone allocation has left less than
>+		 * (sysctl_node_swap / 10) %  of the zone free invoke kswapd.
>+		 * (the page limit is obtained through (pages*limit)/1024 to
>+		 * make the calculation more efficient)
>+		 */
>+		if (z->free_pages < (z->present_pages * sysctl_node_swap) << 10)
>+			wakeup_kswapd(z);
> 	} else {
> 		p->numa_miss++;
> 		zonelist->zones[0]->pageset[cpu].numa_foreign++;
>Index: linux-2.6.9/kernel/sysctl.c
>===================================================================
>  
>

I think you mean >> 10 though.

--Mika


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
