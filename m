Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 864A16B0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 03:05:51 -0400 (EDT)
Date: Wed, 27 Mar 2013 16:05:49 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] mm: remove swapcache page early
Message-ID: <20130327070549.GB13897@blaptop>
References: <1364350932-12853-1-git-send-email-minchan@kernel.org>
 <5152807D.5010905@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5152807D.5010905@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>

Hi Kame,

On Wed, Mar 27, 2013 at 02:15:41PM +0900, Kamezawa Hiroyuki wrote:
> (2013/03/27 11:22), Minchan Kim wrote:
> > Swap subsystem does lazy swap slot free with expecting the page
> > would be swapped out again so we can't avoid unnecessary write.
> > 
> > But the problem in in-memory swap is that it consumes memory space
> > until vm_swap_full(ie, used half of all of swap device) condition
> > meet. It could be bad if we use multiple swap device, small in-memory swap
> > and big storage swap or in-memory swap alone.
> > 
> > This patch changes vm_swap_full logic slightly so it could free
> > swap slot early if the backed device is really fast.
> > For it, I used SWP_SOLIDSTATE but It might be controversial.
> > So let's add Ccing Shaohua and Hugh.
> > If it's a problem for SSD, I'd like to create new type SWP_INMEMORY
> > or something for z* family.
> > 
> > Other problem is zram is block device so that it can set SWP_INMEMORY
> > or SWP_SOLIDSTATE easily(ie, actually, zram is already done) but
> > I have no idea to use it for frontswap.
> > 
> > Any idea?
> > 
> Another thinking....in what case, in what system configuration, 
> vm_swap_full() should return false and delay swp_entry freeing ?

It's a really good question I had have in mind from long time ago.
If I catch your point properly, your question is "Couldn't we remove
vm_swap_full logic?"

If so, the answer is "I have no idea and would like to ask it
to Hugh".

Academically, it does make sense swap-out page is unlikely to be
working set so it could be swap out again and I believe it was
merged since we had the workload could be enhanced by the logic
at that time.

And I think it's not easy to prove it's useless thesedays because
I couldn't have all recent workloads over the world so I'd like to
avoid such adventure. :)

Thanks.

> 
> Thanks,
> -Kame
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
