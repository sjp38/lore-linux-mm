Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l0P64DgM071456
	for <linux-mm@kvack.org>; Thu, 25 Jan 2007 17:04:13 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0P5r56q222204
	for <linux-mm@kvack.org>; Thu, 25 Jan 2007 16:53:07 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0P5na6b014594
	for <linux-mm@kvack.org>; Thu, 25 Jan 2007 16:49:36 +1100
Message-ID: <45B844E3.4050203@linux.vnet.ibm.com>
Date: Thu, 25 Jan 2007 11:19:23 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] Limit the size of the pagecache
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com> <45B75208.90208@linux.vnet.ibm.com> <Pine.LNX.4.64.0701240655400.9696@schroedinger.engr.sgi.com> <45B82F41.9040705@linux.vnet.ibm.com> <45B835FE.6030107@redhat.com>
In-Reply-To: <45B835FE.6030107@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, Aubrey Li <aubreylee@gmail.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Getz <rgetz@blackfin.uclinux.org>, "Henn, erich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Rik van Riel wrote:
> Vaidyanathan Srinivasan wrote:
> 
>> In my opinion, once a
>> file page is mapped by the process, then it should be treated at par
>> with anon pages.  Application programs generally do not mmap a file
>> page if the reuse for the content is very low.
> 
> Why not have the VM measure this, instead of making wild
> assumptions about every possible workload out there?

Yes, VM page aging and page replacement algorithm should decide on the
relevance of anon or mmap page.  However we may still need to limit
total pages in memory for a given set of process.

> There are a few databases out there that mmap the whole
> thing.  Sleepycat for one...
> 

That is why my suggestion would be not to touch mmapped pagecache
pages in the current pagecache limit code.  The limit should concern
only unmapped pagecache pages.

When the application unmaps the pages, then instantly we would go over
limit and 'now' unmapped pages can be reclaimed.  This behavior has
been verified with my fix on top of Christoph's patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
