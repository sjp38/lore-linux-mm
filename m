Date: Sat, 6 Nov 2004 16:32:09 +0100
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: [PATCH] Remove OOM killer from try_to_free_pages / all_unreclaimable braindamage
Message-ID: <20041106153209.GC3851@dualathlon.random>
References: <20041105200118.GA20321@logos.cnet> <200411051532.51150.jbarnes@sgi.com> <20041106012018.GT8229@dualathlon.random> <418C2861.6030501@cyberone.com.au> <20041106015051.GU8229@dualathlon.random> <16780.46945.925271.26168@thebsh.namesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16780.46945.925271.26168@thebsh.namesys.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Nick Piggin <piggin@cyberone.com.au>, Jesse Barnes <jbarnes@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Nov 06, 2004 at 02:37:05PM +0300, Nikita Danilov wrote:
> We need page-reservation API of some sort. There were several attempts
> to introduce this, but none get into mainline.

they're already in under the name of mempools

I'm perfectly aware the fs tends to be the less correct places in terms
of allocations, and luckily it's not an heavy memory user, so I still
have to see a deadlock in getblk or create_buffers or similar. It's
mostly a correctness issue (math proof it can't deadlock, right now it
can if more tasks all get stuck in getblk at the same time during a hard
oom condition etc..).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
