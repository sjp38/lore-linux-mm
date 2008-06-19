Date: Thu, 19 Jun 2008 14:25:10 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only
 pte and _count=2?
In-Reply-To: <200806192253.16880.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0806191413450.23991@blonde.site>
References: <20080618164158.GC10062@sgi.com> <200806192207.40838.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0806191321030.15095@blonde.site> <200806192253.16880.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Robin Holt <holt@sgi.com>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Jun 2008, Nick Piggin wrote:
> On Thursday 19 June 2008 22:34, Hugh Dickins wrote:
> >
> > I doubt it's an accurate swapcount, just a case where one can be
> > sure of !page_swapcount.  It's certainly not something to take on
> > trust, patches I need to be sceptical about and refresh my mind on.
> 
> I don't know if you can be sure of that, because after checking
> page_mapcount, but before checking page_swapcount, can't another
> process have moved their swapcount to mapcount?

Obviously that's the concern.  I need to go over the whole patch
and refresh my mind on this area before I can give you an answer.

> > > I expect Robin could just as well fix it for
> > > their code in the meantime by using force=0...
> >
> > Sorry, please explain, I don't see that: though their driver happens
> > to say force=1, I don't think it's needed and I don't think it's
> > making any difference in this case.
> 
> Oh, I missed that. You're now thinking they do have VM_WRITE on
> the vma and hence your patch isn't going to work (and neither
> force=0). OK, that sounds right to me.

I'm still confused.  I thought all along that they have VM_WRITE on
the vma, which Robin has (by implication) confirmed when he says that
userspace is trying to write to the same page - I don't think he'd
expect it to be able to do so without VM_WRITE.

And my gup patch may (I'm unsure, I haven't tried to picture the whole
sequence again) still be useful in the case that they do have VM_WRITE,
but it would make no difference if they didn't have VM_WRITE.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
