Date: Fri, 12 Sep 2008 18:46:50 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC PATCH] discarding swap
In-Reply-To: <1221236528.21323.22.camel@macbook.infradead.org>
Message-ID: <Pine.LNX.4.64.0809121845040.17067@blonde.site>
References: <Pine.LNX.4.64.0809092222110.25727@blonde.site>
 <20080910173518.GD20055@kernel.dk>  <Pine.LNX.4.64.0809102015230.16131@blonde.site>
  <1221082117.13621.25.camel@macbook.infradead.org>
 <Pine.LNX.4.64.0809121154430.12812@blonde.site>  <1221228567.3919.35.camel@macbook.infradead.org>
  <Pine.LNX.4.64.0809121631050.5142@blonde.site> <1221236528.21323.22.camel@macbook.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Sep 2008, David Woodhouse wrote:
> On Fri, 2008-09-12 at 16:52 +0100, Hugh Dickins wrote:
> > On Fri, 12 Sep 2008, David Woodhouse wrote:
> > > On Fri, 2008-09-12 at 13:10 +0100, Hugh Dickins wrote:
> > > > So long as the I/O schedulers guarantee that a WRITE bio submitted
> > > > to an area already covered by a DISCARD_NOBARRIER bio cannot pass that
> > > > DISCARD_NOBARRIER - ...
> > > 
> > > No, that's the point. the I/O schedulers _don't_ give you that guarantee
> > > at all. They can treat DISCARD_NOBARRIER just like a write. That's all
> > > it is, really -- a special kind of WRITE request without any data.
> > 
> > Hmmm.  In that case I'll need to continue with DISCARD_BARRIER,
> > unless/until I rejig swap allocation to wait for discard completion,
> > which I've no great desire to do.

I'll leave it to Jens to comment on your reply, but I'd like to go
back and add in a further, orthogonal concern or misunderstanding here.

Am I right to be a little perturbed by blk_partition_remap()
and the particular stage at which it's called?

Does it imply that a _BARRIER on swap would have the effect of
inserting a barrier into, say, root and home I/Os too, if swap
and root and home were in separate partitions on the same storage?

Whereas a filesystem would logically only want a barrier to span
its own partition?  (I'm ignoring md/dm.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
