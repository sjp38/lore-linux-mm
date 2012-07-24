Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 707756B004D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 22:24:29 -0400 (EDT)
Date: Tue, 24 Jul 2012 11:24:49 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/3] zsmalloc: s/firstpage/page in new copy map funcs
Message-ID: <20120724022449.GA14411@bbox>
References: <1342630556-28686-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <500DCBDF.5090800@linux.vnet.ibm.com>
 <20120723222749.GA25533@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120723222749.GA25533@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Hi Greg,

On Mon, Jul 23, 2012 at 03:27:49PM -0700, Greg Kroah-Hartman wrote:
> On Mon, Jul 23, 2012 at 05:10:39PM -0500, Seth Jennings wrote:
> > Greg,
> > 
> > I know it's the first Monday after a kernel release and
> > things are crazy for you.  I was hoping to get this zsmalloc
> > stuff in before the merge window hit so I wouldn't have to
> > bother you :-/  But, alas, it didn't happen that way.
> 
> Nope, sorry, it missed them.  It needed to be at least a week previous
> to when the final kernel comes out to get into the next one.
> 
> > Minchan acked these yesterday.  When you get a chance, could
> > you pull these 3 patches?  I'm wanting to send out a
> > promotion patch for zsmalloc and zcache based on these.
> 
> Sorry, it will have to wait until after 3.6-rc1 is out before I will add
> them to my tree for 3.7, that's the merge rules, that you well know :)

I think it is good time that zram/zsmalloc is out of staging because of
removing arch dependency and many clean up with some bug fix.
I hope it's out of staging in this chance.
If you have a concern about that, please let me know it.

Thanks!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
