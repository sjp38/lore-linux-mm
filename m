From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16780.46945.925271.26168@thebsh.namesys.com>
Date: Sat, 6 Nov 2004 14:37:05 +0300
Subject: Re: [PATCH] Remove OOM killer from try_to_free_pages / all_unreclaimable braindamage
In-Reply-To: <20041106015051.GU8229@dualathlon.random>
References: <20041105200118.GA20321@logos.cnet>
	<200411051532.51150.jbarnes@sgi.com>
	<20041106012018.GT8229@dualathlon.random>
	<418C2861.6030501@cyberone.com.au>
	<20041106015051.GU8229@dualathlon.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@novell.com>
Cc: Nick Piggin <piggin@cyberone.com.au>, Jesse Barnes <jbarnes@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli writes:
 > On Sat, Nov 06, 2004 at 12:26:57PM +1100, Nick Piggin wrote:
 > > need to be performed and have no failure path. For example __GFP_REPEAT.
 > 
 > all allocations should have a failure path to avoid deadlocks. But in

This is not currently possible for a complex operation that allocates
multiple pages and has always complete as a whole.

We need page-reservation API of some sort. There were several attempts
to introduce this, but none get into mainline.

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
