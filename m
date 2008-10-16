Subject: Re: no way to swapoff a deleted swap file?
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20081015202141.GX26067@cordes.ca>
References: <20081015202141.GX26067@cordes.ca>
Content-Type: text/plain
Date: Thu, 16 Oct 2008 10:28:04 +0200
Message-Id: <1224145684.28131.25.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Cordes <peter@cordes.ca>
Cc: linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, hugh <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-10-15 at 17:21 -0300, Peter Cordes wrote:
> I unlinked a swapfile without realizing I was still swapping on it.
> Now my /proc/swaps looks like this:
> Filename                                Type            Size    Used	Priority
> /var/tmp/EXP/cache/swap/1\040(deleted)  file            1288644 1448	-1
> /var/tmp/EXP/cache/swap/2\040(deleted)  file            1433368 0	-2
> 
>  AFAICT, there's nothing I can pass to swapoff(2) that will make the
> kernel let go of them.  If that's the case, please consider this a
> feature request for a way to do this.  Now I'm going to have to reboot
> before I can mkfs that partition.
> 
>  If kswapd0 had a fd open on the swap files, swapoff /proc/$PID/fd/3
> could possibly work.  But it looks like the files are open but with no
> user-space accessable file descriptors to them.  Which makes sense,
> except for this case.

Right, except that kswapd is per node, so we'd either have to add it to
all kswapd instances or a random one. Also, kthreads don't seem to have
a files table afaict.

But yes, I see your problem and it makes sense to look for a nice
solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
