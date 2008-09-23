Date: Tue, 23 Sep 2008 21:15:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in /proc/pid/smaps
In-Reply-To: <1222102098.8533.62.camel@nimitz>
References: <20080922162152.GB7716@csn.ul.ie> <1222102098.8533.62.camel@nimitz>
Message-Id: <20080923211140.DC16.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > The corollary is that someone running with a 64K base page kernel may be
> > surprised that the pagesize is always 4K. However I'll check if there is
> > a simple way of checking out if the MMU size differs from PAGE_SIZE.
> 
> Sure.  If it isn't easy, the best thing to do is probably just to
> document the "interesting" behavior.

Dave, please let me know getpagesize() function return to 4k or 64k on ppc64.
I think the PageSize line of the /proc/pid/smap and getpagesize() result should be matched.

otherwise, enduser may be confused.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
