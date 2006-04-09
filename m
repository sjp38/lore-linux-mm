Date: Sun, 9 Apr 2006 04:11:29 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Page Migration: Make do_swap_page redo the fault
In-Reply-To: <Pine.LNX.4.64.0604081430280.17911@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0604090357350.5312@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0604032228150.24182@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0604081312200.14441@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0604081058290.16914@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0604082022170.12196@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0604081430280.17911@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Apr 2006, Christoph Lameter wrote:
> On Sat, 8 Apr 2006, Hugh Dickins wrote:
> > 
> > Sure, those are long standing checks, necessary long before migration
> > came on the scene; whereas the check in do_swap_page was recently added
> > just for a page migration case, and now turns out to be redundant.
> 
> Those two checks were added for migration together with the one we 
> are removing now. Sounds like you think they additionally fix some other 
> race conditions?

Of course, you're right - sorry.  Whatever was I looking at,
to get it so confidently wrong?  Dunno: scary.

But I do have to worry then.  I'd missed the addition of those checks:
if they really are necessary, then the rules have changed in two
tricky areas I now need to re-understand.  It'll take me a while.

Thanks for setting me straight.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
