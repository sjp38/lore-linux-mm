Date: Tue, 10 Jul 2007 10:17:20 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC][PATCH] hugetlbfs read support
Message-ID: <20070710091720.GA28371@infradead.org>
References: <1184009291.31638.8.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1184009291.31638.8.camel@dyn9047017100.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, nacc@us.ibm.com, clameter@sgi.com, Bill Irwin <bill.irwin@oracle.com>, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, Jul 09, 2007 at 12:28:11PM -0700, Badari Pulavarty wrote:
> Comments/flames ?
> 
> Thanks,
> Badari
> 
> Support for reading from hugetlbfs files. libhugetlbfs lets application
> text/data to be placed in large pages. When we do that, oprofile doesn't
> work - since it tries to read from it.
> 
> This code is very similar to what do_generic_mapping_read() does, but
> I can't use it since it has PAGE_CACHE_SIZE assumptions. Christoph
> Lamater's cleanup to pagecache would hopefully give me all of this.

The code looks fine, but I really hate that we need it all all.  We really
should make the general VM/FS code large page aware and get rid of this
whole hack called hugetlbfs..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
