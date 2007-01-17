Subject: Re: [PATCH] nfs: fix congestion control
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1169070763.5975.70.camel@lappy>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
	 <20070116135325.3441f62b.akpm@osdl.org> <1168985323.5975.53.camel@lappy>
	 <Pine.LNX.4.64.0701171158290.7397@schroedinger.engr.sgi.com>
	 <1169070763.5975.70.camel@lappy>
Content-Type: text/plain
Date: Wed, 17 Jan 2007 16:54:46 -0500
Message-Id: <1169070886.6523.8.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-01-17 at 22:52 +0100, Peter Zijlstra wrote:

> > 
> > > Index: linux-2.6-git/fs/inode.c
> > > ===================================================================
> > > --- linux-2.6-git.orig/fs/inode.c	2007-01-12 08:03:47.000000000 +0100
> > > +++ linux-2.6-git/fs/inode.c	2007-01-12 08:53:26.000000000 +0100
> > > @@ -81,6 +81,7 @@ static struct hlist_head *inode_hashtabl
> > >   * the i_state of an inode while it is in use..
> > >   */
> > >  DEFINE_SPINLOCK(inode_lock);
> > > +EXPORT_SYMBOL_GPL(inode_lock);
> > 
> > Hmmm... Commits to all NFS servers will be globally serialized via the 
> > inode_lock?
> 
> Hmm, right, thats not good indeed, I can pull the call to
> nfs_commit_list() out of that loop.

There is no reason to modify any of the commit stuff. Please just drop
that code.

Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
