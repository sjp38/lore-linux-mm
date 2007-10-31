Date: Wed, 31 Oct 2007 18:42:20 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 2/5] hugetlb: Fix quota management for private mappings
In-Reply-To: <1193842481.18417.133.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0710311836040.17125@blonde.wat.veritas.com>
References: <20071030204554.16585.80588.stgit@kernel>
 <20071030204615.16585.60817.stgit@kernel>  <20071030162219.511394fb.akpm@linux-foundation.org>
  <Pine.LNX.4.64.0710301626580.16022@schroedinger.engr.sgi.com>
 <1193842481.18417.133.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@kvack.org, kenchen@google.com, apw@shadowen.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 31 Oct 2007, Adam Litke wrote:
> On Tue, 2007-10-30 at 16:28 -0700, Christoph Lameter wrote:
> > 
> > The private pointer in the first page of a compound page is always 
> > available. However, why do we not use page->mapping for that purpose? 
> > Could we stay as close as possible to regular page cache field use?
> 
> There is an additional problem I forgot to mention in the previous mail.
> The remove_from_page_cache() call path clears page->mapping.  This means
> that if the free_huge_page destructor is called on a previously shared
> page, we will not have the needed information to release quota.  Perhaps
> this is a further indication that use of page->mapping at this level is
> inappropriate. 

Or is it an indication that use of a struct address_space pointer
at this level is inappropriate?  What guarantee do you have at
free_huge_page time, that the memory once used for that struct
address_space is still being used for the same?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
