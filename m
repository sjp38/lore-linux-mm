Date: Tue, 10 Jul 2007 09:10:57 -0700
From: Bill Irwin <bill.irwin@oracle.com>
Subject: Re: [RFC][PATCH] hugetlbfs read support
Message-ID: <20070710161057.GW26380@holomorphy.com>
References: <1184009291.31638.8.camel@dyn9047017100.beaverton.ibm.com> <20070710091720.GA28371@infradead.org> <20070710152846.GD27655@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070710152846.GD27655@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>, Badari Pulavarty <pbadari@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>, clameter@sgi.com, Bill Irwin <bill.irwin@oracle.com>, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, Jul 10, 2007 at 08:28:46AM -0700, Nishanth Aravamudan wrote:
> I agree and sounds like something to bring up at KS (again?) or the
> VM/FS summit. But, for now, hugetlbfs is the supported interface and
> libhugetlbfs has run into this issue supporting one of its features. So
> I would like to see this make it in.
> Just my $0.02 as a libhuge developer.

It should also be there to make it more like a normal filesystem,
though your use case is of vastly higher priority than such concerns.

As far as large pages for the generic VM/VFS, I cast my absentee
vote(s) in favor of such, not that anyone gives a damn what I think.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
