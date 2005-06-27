Message-Id: <200506271814.j5RIEwg22390@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [rfc] lockless pagecache
Date: Mon, 27 Jun 2005 11:14:58 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <42BFC10E.50204@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Nick Piggin' <nickpiggin@yahoo.com.au>, Lincoln Dale <ltd@cisco.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote on Monday, June 27, 2005 2:04 AM
> >> However I think for Oracle and others that use shared memory like
> >> this, they are probably not doing linear access, so that would be a
> >> net loss. I'm not completely sure (I don't have access to real loads
> >> at the moment), but I would have thought those guys would have looked
> >> into fault ahead if it were a possibility.
> > 
> > 
> > i thought those guys used O_DIRECT - in which case, wouldn't the page 
> > cache not be used?
> > 
> 
> Well I think they do use O_DIRECT for their IO, but they need to
> use the Linux pagecache for their shared memory - that shared
> memory being the basis for their page cache. I think. Whatever
> the setup I believe they have issues with the tree_lock, which is
> why it was changed to an rwlock.

Typically shared memory is used as db buffer cache, and O_DIRECT is
performed on these buffer cache (hence O_DIRECT on the shared memory).
You must be thinking some other workload.  Nevertheless, for OLTP type
of db workload, tree_lock hasn't been a problem so far.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
