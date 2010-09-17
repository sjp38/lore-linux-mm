Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 50DC76B0078
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 12:38:00 -0400 (EDT)
Date: Fri, 17 Sep 2010 09:36:36 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [stable] breaks 2.6.32.21+
Message-ID: <20100917163636.GA2916@kroah.com>
References: <1281261197-8816-1-git-send-email-shijie8@gmail.com>
 <4C5EA651.7080009@kernel.org>
 <20100916213603.GW6447@anguilla.noreply.org>
 <20100916231307.GB24617@kroah.com>
 <4C937177.1090909@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C937177.1090909@kernel.org>
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Peter Palfrader <peter@palfrader.org>, stable@kernel.org, Huang Shijie <shijie8@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 17, 2010 at 03:47:35PM +0200, Tejun Heo wrote:
> On 09/17/2010 01:13 AM, Greg KH wrote:
> > Odd, someone just reported the same problem for .35-stable as well.
> > 
> > Tejun, what's going on here?
> 
> Please drop it.  The memory leak was introduced after 2.6.36-rc1.  I
> got confused which commit was in which kernel.  I'll be more careful
> with stable cc's.  Sorry about that.

No problem, now dropped.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
