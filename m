Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l0PK91Pr7667748
	for <linux-mm@kvack.org>; Thu, 25 Jan 2007 19:09:01 -0100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0P8AggT224900
	for <linux-mm@kvack.org>; Thu, 25 Jan 2007 19:10:42 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0P87Cc4031103
	for <linux-mm@kvack.org>; Thu, 25 Jan 2007 19:07:13 +1100
Message-ID: <45B8652B.5040200@linux.vnet.ibm.com>
Date: Thu, 25 Jan 2007 13:37:07 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] Limit the size of the pagecache
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com> <1169625333.4493.16.camel@taijtu> <45B7561C.9000102@yahoo.com.au> <Pine.LNX.4.64.0701240657130.9696@schroedinger.engr.sgi.com> <20070124200614.GA25690@codepoet.org> <Pine.LNX.4.64.0701241840090.12325@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0701241840090.12325@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Erik Andersen <andersen@codepoet.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Aubrey Li <aubreylee@gmail.com>, Robin Getz <rgetz@blackfin.uclinux.org>, "Henn, erich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Christoph Lameter wrote:
> On Wed, 24 Jan 2007, Erik Andersen wrote:
> 
>> It would be far more useful if an application could hint to the
>> pagecache as to which files are and which files as not worth
>> caching, especially when the application knows a priori that data
>> from a particular file will or will not ever be reused.
> 
> It can give such hints via madvise(2).

I think you meant fadvise.  That is certainly a possibility which we
need to work on.  Current implementation of fadvise only throttles
read ahead in case of sequential access and flushes the file in case
of DONTNEED.  We leave it at default for NOREUSE.

In case of DONTNEED and NOREUSE, we need to limit the pages used for
page cache and also reclaim them as soon as possible.  Interaction of
 mmap() and fadvise is little more dfficult to handle.

--Vaidy

> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
