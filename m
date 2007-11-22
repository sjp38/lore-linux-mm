Date: Wed, 21 Nov 2007 16:06:09 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Page allocator: Get rid of the list of cold pages
In-Reply-To: <20071121235849.GG31674@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0711211605010.4556@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711141148200.18811@schroedinger.engr.sgi.com>
 <20071115162706.4b9b9e2a.akpm@linux-foundation.org> <20071121222059.GC31674@csn.ul.ie>
 <Pine.LNX.4.64.0711211434290.3809@schroedinger.engr.sgi.com>
 <20071121230041.GE31674@csn.ul.ie> <Pine.LNX.4.64.0711211530370.4383@schroedinger.engr.sgi.com>
 <20071121235849.GG31674@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, apw@shadowen.org, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Nov 2007, Mel Gorman wrote:

> I didn't think you were going to roll a patch and had queued this
> slightly more agressive version. I think it is a superset of what your
> patch does.

Looks okay.

Also note that you can avoid mmap_sem cacheline bouncing by having 
separate address spaces. Forking a series of processes that then fault 
pages each into their own address space will usually do the trick.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
