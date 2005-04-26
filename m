Date: Tue, 26 Apr 2005 01:18:17 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: VM 4/8 dont-rotate-active-list
Message-Id: <20050426011817.4fa16313.akpm@osdl.org>
In-Reply-To: <17005.63388.871003.456599@gargle.gargle.HOWL>
References: <16994.40620.892220.121182@gargle.gargle.HOWL>
	<20050425205141.0b756263.akpm@osdl.org>
	<17005.63388.871003.456599@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
> Andrew Morton writes:
> 
> [...]
> 
>  > 
>  > I'll plop this into -mm to see what happens.  That should give us decent
>  > stability testing, but someone is going to have to do a ton of performance
>  > testing to justify an upstream merge, please.
> 
> I decided to drop this patch locally, actually. The version you merged
> doesn't behave as advertised: due to merge error l_active is not used in
> refill_inactive_zone() at all. As a result all mapped pages are simply
> parked behind scan page.
> 
> In my micro-benchmark workload (cyclical dirtying of mmaped file larger
> than physical memory) this obviously helps, because reclaim_mapped state
> is quickly reached and after that, mapped pages fall through to inactive
> list independently of their referenced bits. But such behavior is hard
> to justify in a general case.

Ah.

> Once I fixed the patch to take page_referenced() into account it stopped
> making any improvement in mmap micro-benchmark. But hey, if it is
> already in -mm let's test it, nobody understands how VM should work
> anyway. :-)

Sorry, I think I'll drop it in that case - making multiple changes at the
same time produces confusing results sometimes so let's minimise the number
of variables if there's an opportunity to do so.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
