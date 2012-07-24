Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 5AF846B004D
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 10:54:11 -0400 (EDT)
Received: by yhr47 with SMTP id 47so8292052yhr.14
        for <linux-mm@kvack.org>; Tue, 24 Jul 2012 07:54:10 -0700 (PDT)
Date: Tue, 24 Jul 2012 07:54:05 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/3] zsmalloc: s/firstpage/page in new copy map funcs
Message-ID: <20120724145405.GA22778@kroah.com>
References: <1342630556-28686-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <500DCBDF.5090800@linux.vnet.ibm.com>
 <20120723222749.GA25533@kroah.com>
 <20120724022449.GA14411@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120724022449.GA14411@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: devel@driverdev.osuosl.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On Tue, Jul 24, 2012 at 11:24:49AM +0900, Minchan Kim wrote:
> Hi Greg,
> 
> On Mon, Jul 23, 2012 at 03:27:49PM -0700, Greg Kroah-Hartman wrote:
> > On Mon, Jul 23, 2012 at 05:10:39PM -0500, Seth Jennings wrote:
> > > Greg,
> > > 
> > > I know it's the first Monday after a kernel release and
> > > things are crazy for you.  I was hoping to get this zsmalloc
> > > stuff in before the merge window hit so I wouldn't have to
> > > bother you :-/  But, alas, it didn't happen that way.
> > 
> > Nope, sorry, it missed them.  It needed to be at least a week previous
> > to when the final kernel comes out to get into the next one.
> > 
> > > Minchan acked these yesterday.  When you get a chance, could
> > > you pull these 3 patches?  I'm wanting to send out a
> > > promotion patch for zsmalloc and zcache based on these.
> > 
> > Sorry, it will have to wait until after 3.6-rc1 is out before I will add
> > them to my tree for 3.7, that's the merge rules, that you well know :)
> 
> I think it is good time that zram/zsmalloc is out of staging because of
> removing arch dependency and many clean up with some bug fix.
> I hope it's out of staging in this chance.
> If you have a concern about that, please let me know it.

That would have to wait until 3.7, moving it out is not for 3.6, sorry.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
