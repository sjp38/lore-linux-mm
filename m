Date: Thu, 9 Dec 2004 22:02:15 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] Remove OOM killer from try_to_free_pages / all_unreclaimable braindamage
Message-ID: <20041210060215.GK2714@holomorphy.com>
References: <20041106152903.GA3851@dualathlon.random> <Pine.LNX.4.44.0411061609520.3592-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0411061609520.3592-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrea Arcangeli <andrea@novell.com>, Nick Piggin <piggin@cyberone.com.au>, Jesse Barnes <jbarnes@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Nov 2004, Andrea Arcangeli wrote:
>> btw, PF_MEMDIE has always been racy in the way it's being set, so it can
>> corrupt the p->flags, but the race window is very small to trigger it
>> (and even if it triggers, it probably wouldn't be fatal). That's why I
>> don't use PF_MEMDIE in 2.4-aa.

On Sat, Nov 06, 2004 at 04:21:33PM +0000, Hugh Dickins wrote:
> I expect so, yes, the PF_ flags don't have proper locking.  Those
> places which set or clear PF_MEMALLOC are more likely to hit races,
> but last time I went there I don't think there was a real serious problem.

I posted a testcase that triggers a panic with the PF_MEMALLOC race.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
