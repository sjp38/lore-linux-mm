Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BC5EE6B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 15:47:16 -0500 (EST)
Subject: Re: [PATCH 2/7] mmc: Don't use PF_MEMALLOC
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <4B029C40.2020803@gmail.com>
References: <20091117161711.3DDA.A69D9226@jp.fujitsu.com>
	 <20091117102903.7cb45ff3@lxorguk.ukuu.org.uk>
	 <20091117200618.3DFF.A69D9226@jp.fujitsu.com>  <4B029C40.2020803@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 17 Nov 2009 21:47:06 +0100
Message-ID: <1258490826.3918.29.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mmc@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-11-17 at 21:51 +0900, Minchan Kim wrote:
> I think it's because mempool reserves memory. 
> (# of I/O issue\0 is hard to be expected.
> How do we determine mempool size of each block driver?
> For example,  maybe, server use few I/O for nand. 
> but embedded system uses a lot of I/O. 

No, you scale the mempool to the minimum amount required to make
progress -- this includes limiting the 'concurrency' when handing out
mempool objects.

If you run into such tight corners often enough to notice it, there's
something else wrong.

I fully agree with ripping out PF_MEMALLOC from pretty much everything,
including the VM, getting rid of the various abuse outside of the VM
seems like a very good start.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
