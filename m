Message-ID: <48AC25E7.4090005@linux-foundation.org>
Date: Wed, 20 Aug 2008 09:10:47 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/2] Quicklist is slighly problematic.
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Hi Cristoph,
> 
> Thank you for explain your quicklist plan at OLS.
> 
> So, I made summary to issue of quicklist.
> if you have a bit time, Could you please read this mail and patches?
> And, if possible, Could you please tell me your feeling?

I believe what I said at the OLS was that quicklists are fundamentally crappy
and should be replaced by something that works (Guess that is what you meant
by "plan"?). Quicklists were generalized from the IA64 arch code.

Good fixup but I would think that some more radical rework is needed.

Maybe some of this needs to vanish into the TLB handling logic?

Then I have thought for awhile that the main reason that quicklists exist are
the performance problems in the page allocator. If you can make the single
page alloc / free pass competitive in performance with quicklists then we
could get rid of all uses.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
