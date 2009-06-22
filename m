Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 955FE6B004D
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 12:51:02 -0400 (EDT)
Date: Mon, 22 Jun 2009 17:52:36 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Re: Re: Performance degradation seen after using one list for
	hot/cold pages.
Message-ID: <20090622165236.GE3981@csn.ul.ie>
References: <20626261.51271245670323628.JavaMail.weblogic@epml20>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20626261.51271245670323628.JavaMail.weblogic@epml20>
Sender: owner-linux-mm@kvack.org
To: NARAYANAN GOPALAKRISHNAN <narayanan.g@samsung.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 22, 2009 at 11:32:03AM +0000, NARAYANAN GOPALAKRISHNAN wrote:
> Hi,
> 
> We are running on VFAT.
> We are using iozone performance benchmarking tool (http://www.iozone.org/src/current/iozone3_326.tar) for testing.
> 
> The parameters are 
> /iozone -A -s10M -e -U /tmp -f /tmp/iozone_file
> 
> Our block driver requires requests to be merged to get the best performance.
> This was not happening due to non-contiguous pages in all kernels >= 2.6.25.
> 

Ok, by the looks of things, all the aio_read() requests are due to readahead
as opposed to explicit AIO  requests from userspace. In this case, nothing
springs to mind that would avoid excessive requests for cold pages.

It looks like the simpliest solution is to go with the patch I posted.
Does anyone see a better alternative that doesn't branch in rmqueue_bulk()
or add back the hot/cold PCP lists?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
