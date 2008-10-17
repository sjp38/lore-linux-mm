Date: Fri, 17 Oct 2008 11:08:13 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] mm: have expand_stack honour VM_LOCKED
Message-ID: <20081017090813.GA32554@wotan.suse.de>
References: <20081017050120.GA28605@wotan.suse.de> <20081017142346.FAA6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081017142346.FAA6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 17, 2008 at 02:41:31PM +0900, KOSAKI Motohiro wrote:
> Hi Nick,
> 
> > Is this valid?
> > 
> > 
> > It appears that direct callers of expand_stack may not properly lock the newly
> > expanded stack if they don't call make_pages_present (page fault handlers do
> > this).
> 
> When happend this issue?
> 
> I think...
> 
> case 1. explit mlock to stack 
> 
>    1. mlock to stack
>         -> make_pages_present is called via mlock(2).
>    2. stack increased
>         -> no page fault happened.
> 
> case 2. swapout and mlock stack
> 
>    1. stack swap out
>    2. mlock to stack
>         -> the page doesn't swap in at the time.
>    3. page fault in the stack
>         -> the page swap in
>            (no need make_present_page())
> 
> 
> So, it seems this patch isn't necessary.

What if you you page fault the stack further than a single page down?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
