Date: Mon, 30 Jul 2007 22:57:03 -0700 (PDT)
From: dean gaudet <dean@arctic.org>
Subject: Re: [PATCH] hugetlbfs read() support
In-Reply-To: <20070719175207.GH26380@holomorphy.com>
Message-ID: <Pine.LNX.4.64.0707302252080.8176@twinlark.arctic.org>
References: <1184376214.15968.9.camel@dyn9047017100.beaverton.ibm.com>
 <20070718221950.35bbdb76.akpm@linux-foundation.org>
 <1184860309.18188.90.camel@dyn9047017100.beaverton.ibm.com>
 <20070719095850.6e09b0e8.akpm@linux-foundation.org> <20070719170759.GE2083@us.ibm.com>
 <20070719175207.GH26380@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Irwin <bill.irwin@oracle.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Jul 2007, Bill Irwin wrote:

> On Thu, Jul 19, 2007 at 10:07:59AM -0700, Nishanth Aravamudan wrote:
> > But I do think a second reason to do this is to make hugetlbfs behave
> > like a normal fs -- that is read(), write(), etc. work on files in the
> > mountpoint. But that is simply my opinion.
> 
> Mine as well.

ditto.  here's a few other things i've run into recently:

it should be possible to use cp(1) to load large datasets into a 
hugetlbfs.

it should be possible to use ftruncate() on hugetlbfs files.  (on a tmpfs 
it's req'd to extend the file before mmaping... on hugetlbfs it returns 
EINVAL or somesuch and mmap just magically extends files.)

it should be possible to statfs() and get usage info... this works only if 
you mount with size=N.

-dean




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
