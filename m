Date: Fri, 20 Apr 2007 23:45:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: slab allocators: Remove multiple alignment specifications.
Message-Id: <20070420234519.1108ba7b.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0704202330440.11938@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0704202210060.17036@schroedinger.engr.sgi.com>
	<20070420223727.7b201984.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0704202243480.25004@schroedinger.engr.sgi.com>
	<20070420231129.9252ca67.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0704202330440.11938@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2007 23:32:48 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 20 Apr 2007, Andrew Morton wrote:
> 
> > > Sorry. Trees overloaded with series of patches. Any change to get 
> > > a new tree?
> > 
> > rofl.
> > 
> > I'm still recovering from that dang Itanium conference.  Since rc6-mm1 I
> > have added 684 patches and removed 164.  It's simply idiotic.
> > 
> > http://userweb.kernel.org/~akpm/cl.bz2 is the current rollup against rc7. 
> > I haven't tried compiling it for nearly a week.  Good luck ;)
> 
> Well xpmem is broke

What's xpmem?

> and readahead is failing all over the place.

runtime or compiletime?  If the latter, what are the symptoms?

(I'd be shocked if it compiled)

> Some 
> patches missing?

dude, this is why it takes ten-odd hours for me to get a -mm release out.

> Hmmmm... Revoke.c has another copy of these fs constructor flag checks 
> that I fixed earlier.

Yeah, I tossed that hunk because it was miles out of order.  I'll put this
bit into the right place.


> Index: linux-2.6.21-rc7/fs/revoke.c
> ===================================================================
> --- linux-2.6.21-rc7.orig/fs/revoke.c	2007-04-20 23:30:11.000000000 -0700
> +++ linux-2.6.21-rc7/fs/revoke.c	2007-04-20 23:30:33.000000000 -0700
> @@ -709,8 +709,7 @@ static void revokefs_init_inode(void *ob
>  {
>  	struct revokefs_inode_info *info = obj;
>  
> -	if ((flags & (SLAB_CTOR_VERIFY | SLAB_CTOR_CONSTRUCTOR)) ==
> -	    SLAB_CTOR_CONSTRUCTOR) {
> +	if (flags & SLAB_CTOR_CONSTRUCTOR) {
>  		info->owner = NULL;
>  		inode_init_once(&info->vfs_inode);
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
