Date: Tue, 30 Oct 2007 16:28:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/5] hugetlb: Fix quota management for private mappings
In-Reply-To: <20071030162219.511394fb.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0710301626580.16022@schroedinger.engr.sgi.com>
References: <20071030204554.16585.80588.stgit@kernel> <20071030204615.16585.60817.stgit@kernel>
 <20071030162219.511394fb.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, linux-kernel@kvack.org, kenchen@google.com, apw@shadowen.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 30 Oct 2007, Andrew Morton wrote:

> > This patch (based on a prototype provided by Ken Chen) moves quota
> > crediting for all pages into free_huge_page().  page->private is used to
> > store a pointer to the mapping to which this page belongs.  This is used to
> > credit quota on the appropriate hugetlbfs instance.
> > 
> 
> Consuming page.private on hugetlb pages is a noteworthy change.  I'm in
> fact surprised that it's still available.
> 
> I'd expect that others (eg Christoph?) have designs upon it as well.  We
> need to work out if this is the best use we can put it to.

The private pointer in the first page of a compound page is always 
available. However, why do we not use page->mapping for that purpose? 
Could we stay as close as possible to regular page cache field use?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
