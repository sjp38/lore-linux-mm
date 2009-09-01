Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9DC836B004F
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 07:00:33 -0400 (EDT)
Date: Tue, 1 Sep 2009 19:20:43 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: page allocator regression on nommu
Message-ID: <20090901102042.GA15680@linux-sh.org>
References: <20090831074842.GA28091@linux-sh.org> <20090831103056.GA29627@csn.ul.ie> <20090831104315.GB30264@linux-sh.org> <20090831105952.GC29627@csn.ul.ie> <20090901004627.GA531@linux-sh.org> <20090901100356.GA27393@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090901100356.GA27393@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Hansen <dave@linux.vnet.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 01, 2009 at 11:03:56AM +0100, Mel Gorman wrote:
> On Tue, Sep 01, 2009 at 09:46:27AM +0900, Paul Mundt wrote:
> > > What is the output of the following debug patch?
> > > 
> > 
> > ...
> > Inode-cache hash table entries: 1024 (order: 0, 4096 bytes)
> > ------------[ cut here ]------------
> > Badness at mm/page_alloc.c:1046
> > 
> 
> Ok, it looks like ownership was not being taken properly and the first
> patch was incomplete. Please try
> 
That did the trick, everything looks back to normal now. :-)

Tested-by: Paul Mundt <lethal@linux-sh.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
