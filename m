Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 54C868D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 19:03:31 -0500 (EST)
Date: Thu, 10 Mar 2011 00:03:24 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] shmem: put inode if alloc_file failed
Message-ID: <20110310000324.GC22723@ZenIV.linux.org.uk>
References: <1299575700-6901-1-git-send-email-lliubbo@gmail.com>
 <20110309145859.dbe31df5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110309145859.dbe31df5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, hch@lst.de, hughd@google.com, npiggin@kernel.dk

On Wed, Mar 09, 2011 at 02:58:59PM -0800, Andrew Morton wrote:

> > +put_inode:
> > +	iput(inode);
> >  put_dentry:
> >  	path_put(&path);
> >  put_memory:
> 
> Is this correct?  We've linked the inode to the dentry with
> d_instantiate(), so the d_put() will do the iput() on the inode.


ITYM path_put() and yes, it will.  There's no leak.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
