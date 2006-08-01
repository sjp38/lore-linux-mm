Date: Tue, 1 Aug 2006 16:27:49 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch][rfc] possible lock_page fix for Andrea's nopage vs invalidate race?
Message-ID: <20060801142749.GC6455@opteron.random>
References: <44CF3CB7.7030009@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <44CF3CB7.7030009@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 01, 2006 at 09:36:23PM +1000, Nick Piggin wrote:
> Hi,
> 
> Just like to get some thoughts on another possible approach to this
> problem, and whether my changelog and implementation actually capture
> the problem. This fix is actually something Andrea had proposed, so
> credit really goes to him.

The credit for this third possible fix goes to you for sorting out all
the details ;). This is perhaps the cleanest fix even if more
intrusive.

> I suppose we should think about fixing it some day?

I was thinking about this every few days too, but I already submitted
two fixes and I got somewhat contradictory reviews of them, so I
wasn't sure what to do given that for mainline it's mostly a DoS
because the VM lacks the proper bugchecks in the objrmap layer to
autodetect the leak (the bugchecks I'm talking about only exists only
in the sles9 VM, Hugh removed them while merging objrmap into
mainline, and the fact they existed in sles9 is why we noticed and
tracked down this leak). We already fixed the bug in sles9 a while ago
with my second fix, but I obviously agree we have to fix it in
mainline as well some day too, infact I wouldn't mind to add the
bugchecks too to be sure something like this doesn't go unnoticed
again (especially now that in sles10 we're in VM sync with mainline).

I really appreciate this third way being implemented. It looks quite
nice. Great work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
