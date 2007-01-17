Date: Wed, 17 Jan 2007 23:15:54 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] nfs: fix congestion control
Message-ID: <20070117231554.GC9387@infradead.org>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com> <20070116135325.3441f62b.akpm@osdl.org> <1168985323.5975.53.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1168985323.5975.53.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

> --- linux-2.6-git.orig/fs/inode.c	2007-01-12 08:03:47.000000000 +0100
> +++ linux-2.6-git/fs/inode.c	2007-01-12 08:53:26.000000000 +0100
> @@ -81,6 +81,7 @@ static struct hlist_head *inode_hashtabl
>   * the i_state of an inode while it is in use..
>   */
>  DEFINE_SPINLOCK(inode_lock);
> +EXPORT_SYMBOL_GPL(inode_lock);

Btw, big "no fucking way" here.  There is no chance we're going to export
this, even _GPL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
