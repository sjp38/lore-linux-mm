From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc][patch] mm: dirty page accounting hole
Date: Tue, 12 Aug 2008 23:17:12 +1000
References: <200808121558.40130.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0808121210250.31744@blonde.site> <200808122153.46144.nickpiggin@yahoo.com.au>
In-Reply-To: <200808122153.46144.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200808122317.12236.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 12 August 2008 21:53, Nick Piggin wrote:
> On Tuesday 12 August 2008 21:15, Hugh Dickins wrote:
> > On Tue, 12 Aug 2008, Nick Piggin wrote:
> > > I think I'm running into a hole in dirty page accounting...
> > >
> > > What seems to be happening is that a page gets written to via a
> > > VM_SHARED vma. We then set the pte dirty, then mark the page dirty.
> > > Next, mprotect changes the vma so it is no longer writeable so it
> > > is no longer VM_SHARED. The pte is still dirty.
> >
> > I don't think you've got that right yet.
> >
> > mprotect can of course change vma->vm_flags to take VM_WRITE off,
> > making vma no longer writeable; but it shouldn't be touching
> > VM_SHARED.  And a quick check with debugger confirms that.
>
> Drat, yes, I must have been thinking of VM_WRITE vs VM_MAYWRITE.

And indeed I was able to reproduce the problem with my "fix" applied
too, after refining the test case to be more reproduceable...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
