Date: Mon, 29 Jan 2007 17:51:59 -0800
From: Mark Fasheh <mark.fasheh@oracle.com>
Subject: Re: page_mkwrite caller is racy?
Message-ID: <20070130015159.GA14799@ca-server1.us.oracle.com>
Reply-To: Mark Fasheh <mark.fasheh@oracle.com>
References: <45BDCA8A.4050809@yahoo.com.au> <Pine.LNX.4.64.0701291521540.24726@blonde.wat.veritas.com> <45BE9BF0.10202@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45BE9BF0.10202@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@osdl.org>, Anton Altaparmakov <aia21@cam.ac.uk>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 30, 2007 at 12:14:24PM +1100, Nick Piggin wrote:
> This is another discussion, but do we want the page locked here? Or
> are the filesystems happy to exclude truncate themselves?

No page lock please. Generally, Ocfs2 wants to order cluster locks outside
of page locks. Also, the sparse b-tree support I'm working on right now will
need to be able to allocate in ->page_mkwrite() which would become very
nasty if we came in with the page lock - aside from the additional cluster
locks taken, ocfs2 will want to zero some adjacent pages (because we support
atomic allocation up to 1 meg).

Thanks,
	--Mark

--
Mark Fasheh
Senior Software Developer, Oracle
mark.fasheh@oracle.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
