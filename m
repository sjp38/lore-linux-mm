Date: Tue, 10 Jul 2007 08:36:49 -0700
From: Bill Irwin <bill.irwin@oracle.com>
Subject: Re: [RFC][PATCH] hugetlbfs read support
Message-ID: <20070710153649.GU26380@holomorphy.com>
References: <1184009291.31638.8.camel@dyn9047017100.beaverton.ibm.com> <20070710091720.GA28371@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070710091720.GA28371@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>, nacc@us.ibm.com, clameter@sgi.com, Bill Irwin <bill.irwin@oracle.com>, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, Jul 09, 2007 at 12:28:11PM -0700, Badari Pulavarty wrote:
>> This code is very similar to what do_generic_mapping_read() does, but
>> I can't use it since it has PAGE_CACHE_SIZE assumptions. Christoph
>> Lamater's cleanup to pagecache would hopefully give me all of this.

On Tue, Jul 10, 2007 at 10:17:20AM +0100, Christoph Hellwig wrote:
> The code looks fine, but I really hate that we need it all all.  We really
> should make the general VM/FS code large page aware and get rid of this
> whole hack called hugetlbfs..

That needs to be taken up with Linus. If it's any consolation, I'm in
favor of such myself.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
