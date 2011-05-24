Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7C44F6B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 22:52:21 -0400 (EDT)
Date: Mon, 23 May 2011 19:51:51 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: linux-next: build failure after merge of the final tree
Message-ID: <20110524025151.GA26939@kroah.com>
References: <20110520161816.dda6f1fd.sfr@canb.auug.org.au>
 <BANLkTimjzzqTS1fELmpb0UivqseLsYOfPw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTimjzzqTS1fELmpb0UivqseLsYOfPw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Frysinger <vapier.adi@gmail.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Linus <torvalds@linux-foundation.org>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dipankar Sarma <dipankar@in.ibm.com>

On Mon, May 23, 2011 at 10:06:40PM -0400, Mike Frysinger wrote:
> On Fri, May 20, 2011 at 02:18, Stephen Rothwell wrote:
> > Caused by commit e66eed651fd1 ("list: remove prefetching from regular list
> > iterators").
> >
> > I added the following patch for today:
> 
> probably should get added to whatever tree that commit is coming from
> so we dont have bisect hell ?
> 
> more failures:
> drivers/usb/host/isp1362-hcd.c: In function 'isp1362_write_ptd':
> drivers/usb/host/isp1362-hcd.c:355: error: implicit declaration of
> function 'prefetch'
> drivers/usb/host/isp1362-hcd.c: In function 'isp1362_read_ptd':
> drivers/usb/host/isp1362-hcd.c:377: error: implicit declaration of
> function 'prefetchw'
> make[3]: *** [drivers/usb/host/isp1362-hcd.o] Error 1
> 
> drivers/usb/musb/musb_core.c: In function 'musb_write_fifo':
> drivers/usb/musb/musb_core.c:219: error: implicit declaration of
> function 'prefetch'
> make[3]: *** [drivers/usb/musb/musb_core.o] Error 1
> 
> although it seems like it should be fairly trivial to look at the
> funcs in linux/prefetch.h, grep the tree, and find a pretty good list
> of the files that are missing the include

How did this not show up in linux-next?  Where did the patch that caused
this show up from?

totally confused,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
