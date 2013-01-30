Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 9FB6E6B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 03:05:54 -0500 (EST)
Date: Tue, 29 Jan 2013 23:17:39 -0500
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/4] staging: zsmalloc: various cleanups/improvments
Message-ID: <20130130041739.GA24517@kroah.com>
References: <1359135978-15119-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130128034740.GE3321@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130128034740.GE3321@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On Mon, Jan 28, 2013 at 12:47:40PM +0900, Minchan Kim wrote:
> Hi Seth,
> 
> On Fri, Jan 25, 2013 at 11:46:14AM -0600, Seth Jennings wrote:
> > These patches are the first 4 patches of the zswap patchset I
> > sent out previously.  Some recent commits to zsmalloc and
> > zcache in staging-next forced a rebase. While I was at it, Nitin
> > (zsmalloc maintainer) requested I break these 4 patches out from
> > the zswap patchset, since they stand on their own.
> 
> [2/4] and [4/4] is okay to merge current zsmalloc in staging but
> [1/4] and [3/4] is dependent on zswap so it should be part of
> zswap patchset.

I tried to apply patches 2 and 4, but 2 didn't work, so I only applied
4/4.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
