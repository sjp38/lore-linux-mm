Subject: Re: [RFC] Avoiding fragmentation through different allocator
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <20050113070314.GL2995@waste.org>
References: <Pine.LNX.4.58.0501122101420.13738@skynet>
	 <20050113070314.GL2995@waste.org>
Content-Type: text/plain
Date: Thu, 13 Jan 2005 02:20:01 -0500
Message-Id: <1105600801.11555.6.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

on den 12.01.2005 Klokka 23:03 (-0800) skreiv Matt Mackall:

> You might stress higher order page allocation with a) 8k stacks turned
> on b) UDP NFS with large read/write.

   b) Unless your network uses jumbo frames, UDP NFS should not be doing
higher order page allocation.

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
