Date: Mon, 6 Sep 2004 15:37:24 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
Message-ID: <20040906223724.GH3106@holomorphy.com>
References: <413CB661.6030303@sgi.com> <20040906131027.227b99ac.akpm@osdl.org> <413CD4FF.8070408@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <413CD4FF.8070408@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, piggin@cyberone.com.au, kernel@kolivas.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 06, 2004 at 04:22:07PM -0500, Ray Bryant wrote:
> We were planning on suggesting that such users set swappiness=0 to give
> user pages priority over the page cache pages.  But it doesn't look like 
> that works very well in the more recent kernels.
> One (perhaps) desirable feature would be for intermediate values of 
> swappiness to have behavior in between the two extremes (mapped pages have 
> higher priority vs page cache pages having priority over unreferenced 
> mapped pages),
> so that one would have finer grain control over the amount of swap used.  
> I'm not sure how to achieve such a goal, however.  :-)

Priority paging again? A perennial suggestion.


On Mon, Sep 06, 2004 at 04:22:07PM -0500, Ray Bryant wrote:
> On a separate issue, the response to my proposal for a mempolicy to control
> allocation of page cache pages has been <ahem> underwhelming.
> (See: http://marc.theaimsgroup.com/?l=linux-mm&m=109416852113561&w=2
>  and  http://marc.theaimsgroup.com/?l=linux-mm&m=109416852416997&w=2 )
> I wonder if this is because I just posted it to linux-mm or its not fleshed 
> out enough yet to be interesting?

It was very noncontroversial. Since it's apparently useful to someone
and generally low-impact it should probably be merged.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
