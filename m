Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6AIcfPL031689
	for <linux-mm@kvack.org>; Tue, 10 Jul 2007 14:38:41 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6AIcfHc184126
	for <linux-mm@kvack.org>; Tue, 10 Jul 2007 12:38:41 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6AIcevj007251
	for <linux-mm@kvack.org>; Tue, 10 Jul 2007 12:38:40 -0600
Message-ID: <4693D23E.1010805@us.ibm.com>
Date: Tue, 10 Jul 2007 11:38:54 -0700
From: Badari Pulavarty <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] hugetlbfs read support
References: <1184009291.31638.8.camel@dyn9047017100.beaverton.ibm.com> <20070710091720.GA28371@infradead.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, nacc@us.ibm.com, clameter@sgi.com, Bill Irwin <bill.irwin@oracle.com>, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>


Christoph Hellwig wrote:

>On Mon, Jul 09, 2007 at 12:28:11PM -0700, Badari Pulavarty wrote:
>
>>Comments/flames ?
>>
>>Thanks,
>>Badari
>>
>>Support for reading from hugetlbfs files. libhugetlbfs lets application
>>text/data to be placed in large pages. When we do that, oprofile doesn't
>>work - since it tries to read from it.
>>
>>This code is very similar to what do_generic_mapping_read() does, but
>>I can't use it since it has PAGE_CACHE_SIZE assumptions. Christoph
>>Lamater's cleanup to pagecache would hopefully give me all of this.
>>
>
>The code looks fine, but I really hate that we need it all all.  We really
>should make the general VM/FS code large page aware and get rid of this
>whole hack called hugetlbfs..
>
I would love to see *atleast* generic filemap handler routines does not 
assume PAGE_SIZE.
Clameter's cleanup patches hopefully would all of that for us - but I am 
not sure how it handles
largepages with kmap() to copy out the data.

But getting rid of hugetlbfs completely, needs bigger effort :(

Thanks,
Badari



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
