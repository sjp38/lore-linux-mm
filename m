Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7TLjhUl020723
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 17:45:43 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TLjhGh453984
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 17:45:43 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TLjhLu024437
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 17:45:43 -0400
Subject: Re: [RFC:PATCH 00/07] VM File Tails
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
In-Reply-To: <20070829213154.GB29635@lazybastard.org>
References: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
	 <20070829213154.GB29635@lazybastard.org>
Content-Type: text/plain; charset=ISO-8859-1
Date: Wed, 29 Aug 2007 21:45:42 +0000
Message-Id: <1188423942.6529.74.camel@norville.austin.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?ISO-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-08-29 at 23:31 +0200, Jorn Engel wrote:
> On Wed, 29 August 2007 16:53:25 -0400, Dave Kleikamp wrote:
> >
> > - benchmark!
> 
> I'd love to know how much difference this makes.  Basically four
> numbers:
> - number of address spaces
> - bytes allocated for file tails
> - number of pages allocated for non-tail storage
> - number of pages allocated for tail storage

The last one may be tricky, since I'm allocating the tails using
kmalloc.  The data will be interspersed with other kmalloc'ed data.  We
could keep track of the bytes, and the number of tails, but we wouldn't
know exactly how the tail bytes correspond to the number of pages needed
to store them.

> With those it should be possible to calculate how much is saved by using
> tail and how much is wasted by having both tails and a page.  Putting
> this in relation to the total amount of data in page cache is
> interesting as well.
> 
> While not as decisive as benchmarks it may give some indication why
> certain workloads benefit or suffer.
> 
> Jorn
-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
