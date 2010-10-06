Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EC9E16B0071
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 10:13:15 -0400 (EDT)
Date: Wed, 6 Oct 2010 07:02:12 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: OOM panics with zram
Message-ID: <20101006140212.GB19470@kroah.com>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
 <1284053081.7586.7910.camel@nimitz>
 <4CA8CE45.9040207@vflare.org>
 <20101005234300.GA14396@kroah.com>
 <4CABDF0E.3050400@vflare.org>
 <20101006023624.GA27685@kroah.com>
 <4CABFB6F.2070800@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CABFB6F.2070800@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 06, 2010 at 12:30:39AM -0400, Nitin Gupta wrote:
> > So, should I delete the version in staging, or are you going to send
> > patches to sync it up with your development version?
> > 
> 
> Deleting it from staging would not help much. Much more helpful would
> be to sync at least the mainline and linux-next version of the driver
> so it's easier to develop against these kernel trees.  Initially, I
> thought -staging means that any reviewed change can quickly make it
> to *both* linux-next and more importantly -staging in mainline.

It makes it quickly to linux-next, right?

Nothing goes "quickly" to mainline, other than the normal development
process, which is well documented as to how it all works.

> Working/ Testing against mainline is much smoother than against
> linux-next.

Sure it's "easier", but that's not how kernel development is done,
sorry.  See Documentation/development-process/ for details.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
