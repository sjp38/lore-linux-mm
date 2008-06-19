Date: Thu, 19 Jun 2008 08:35:50 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only
	pte and _count=2?
Message-ID: <20080619133550.GB10123@sgi.com>
References: <20080618164158.GC10062@sgi.com> <200806192207.40838.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0806191321030.15095@blonde.site> <200806192253.16880.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0806191413450.23991@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806191413450.23991@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Robin Holt <holt@sgi.com>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 19, 2008 at 02:25:10PM +0100, Hugh Dickins wrote:
> On Thu, 19 Jun 2008, Nick Piggin wrote:
> > On Thursday 19 June 2008 22:34, Hugh Dickins wrote:

> > Oh, I missed that. You're now thinking they do have VM_WRITE on
> > the vma and hence your patch isn't going to work (and neither
> > force=0). OK, that sounds right to me.
> 
> I'm still confused.  I thought all along that they have VM_WRITE on
> the vma, which Robin has (by implication) confirmed when he says that
> userspace is trying to write to the same page - I don't think he'd
> expect it to be able to do so without VM_WRITE.

It does have VM_WRITE set.  I do expect this patch to at least change
the problem.  I am also working on testing (seperately) with force=0 to
verify that does not introduce other regressions.  I am doing this
testing against a sles10 kernel and not Linus' latest and greatest.  I
will try to test Linus' kernel later, but that will take more time.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
