Date: Fri, 17 Oct 2008 15:55:28 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] mm: have expand_stack honour VM_LOCKED
Message-ID: <20081017135528.GA6694@wotan.suse.de>
References: <20081017050120.GA28605@wotan.suse.de> <Pine.LNX.4.64.0810171416090.3111@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0810171416090.3111@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 17, 2008 at 02:42:56PM +0100, Hugh Dickins wrote:
> On Fri, 17 Oct 2008, Nick Piggin wrote:
> 
> > Is this valid?
> 
> Well.  I find it really hard to get excited about the case of
> a stack fault more than a page below the current stack pointer not
> faulting in the intervening untouched pages when the stack is mlocked.
> 
> (That's what it amounts to, isn't it? though your description doesn't
> make that at all clear.)
> 
> Do you have a case where it actually matters e.g. does get_user_pages
> or something like it assume that every page in a VM_LOCKED area must
> already be present?  Or do you worry that we might easily add such
> an assumption?
> 
> I don't think your patch is wrong, but I'd feel a wee bit safer just
> to leave things as is: somehow, I prefer the idea of the arch fault
> routines faulting in the (normal case) one page for themselves, than
> it happening underneath them in make_pages_present's get_user_pages.
> 
> One minor (ha ha) defect of doing it your way is that the minor fault
> will get counted twice.
> 
> But I don't feel strongly about it.

No, no "real" case in mind, I was just looking at the code.

How do critical apps reserve and lock a required amount of stack? I
thought there might be cases where failing to lock pages could cause
problems there.

Minor faults... good spotting :) I don't think I'd worry about that
yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
