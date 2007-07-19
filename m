Date: Fri, 20 Jul 2007 08:18:05 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch] fix periodic superblock dirty inode flushing
Message-ID: <20070719221805.GY31489@sgi.com>
References: <b040c32a0707112121y21d08438u8ca7f138931827b0@mail.gmail.com> <20070712120519.8a7241dd.akpm@linux-foundation.org> <b040c32a0707131517m4cc20d3an2123e324746d3e7@mail.gmail.com> <b040c32a0707161701q49ad150di6387b029a39b39c3@mail.gmail.com> <384813965.25550@ustc.edu.cn> <20070718201018.9beb0f90.akpm@linux-foundation.org> <384832548.21788@ustc.edu.cn> <20070719011845.3e747a56.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070719011845.3e747a56.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <fengguang.wu@gmail.com>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 19, 2007 at 01:18:45AM -0700, Andrew Morton wrote:
> On Thu, 19 Jul 2007 16:09:10 +0800 Fengguang Wu <fengguang.wu@gmail.com> wrote:
> > On Wed, Jul 18, 2007 at 08:10:18PM -0700, Andrew Morton wrote:
> > > With an indexed data structure (ie: radix-tree or rbtree) the writeback
> > > code can remember where it was up to in the ordered list of inodes so it
> > > can drop locks, do writeback, remember where it was up to for the next
> > > pass, etc.
> > > 
> > > Basically, the walk of the per-superblock inodes would follow the same
> > > model as the walk of the per-inode pages.  And the latter has worked out
> > > *really* well.  It would be great if the per-sb inode traversal was as
> > > flexible and as powerful as the page walks.
> > > 
> > > Probably it never will be, because I suspect we'd need to order the inodes
> > > by multiple indices.  I hn't thought it through, really.  
> > 
> > Just one more possibility...  an array of lists?
> > 
> > The array is cyclic and time-addressable, and
> > the lists can be ordered by other criterion(s).
> 
> Yeah, something like that.
> 
> The array would need to be dynamically sizeable and capable of
> efficiently supporting large holes.  ie: a radix-tree or rbtree ;)

You mean sorta like fs/xfs/xfs_mru_cache.[ch]?

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
