Date: Tue, 10 Jul 2007 11:53:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH] hugetlbfs read support
In-Reply-To: <20070710153752.GV26380@holomorphy.com>
Message-ID: <Pine.LNX.4.64.0707101152190.12299@schroedinger.engr.sgi.com>
References: <1184009291.31638.8.camel@dyn9047017100.beaverton.ibm.com>
 <20070710153752.GV26380@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Irwin <bill.irwin@oracle.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>, nacc@us.ibm.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jul 2007, Bill Irwin wrote:

> On Mon, Jul 09, 2007 at 12:28:11PM -0700, Badari Pulavarty wrote:
> > Support for reading from hugetlbfs files. libhugetlbfs lets application
> > text/data to be placed in large pages. When we do that, oprofile doesn't
> > work - since it tries to read from it.
> > This code is very similar to what do_generic_mapping_read() does, but
> > I can't use it since it has PAGE_CACHE_SIZE assumptions. Christoph
> > Lamater's cleanup to pagecache would hopefully give me all of this.
> > Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> 
> What's the testing status of all this? I thoroughly approve of the
> concept, of course.

The status is that Andrew has doubts about the antifrag approach etc 
which will stall all of this if the antifrag does not get merged. See 
the mm-merge discussion on lkml. Please make noise. Andrew asked for it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
