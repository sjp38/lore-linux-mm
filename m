Date: Sat, 7 Jun 2008 21:32:10 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH -mm 15/25] Ramfs and Ram Disk pages are non-reclaimable
Message-ID: <20080608043210.GB21251@kroah.com>
References: <20080606202838.390050172@redhat.com> <20080606202859.408662219@redhat.com> <20080606180510.87a49e19.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080606180510.87a49e19.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, Jun 06, 2008 at 06:05:10PM -0700, Andrew Morton wrote:
> 
> Also, I expect there are a whole host of pseudo-filesystems (sysfs?)
> which have this problem.  Does the patch address all of them?  If not,
> can we come up with something which _does_ address them all without
> having to hunt down and change every such fs?

sysfs used to have this issue, until the people at IBM rewrote the whole
backing store for sysfs so that now it is reclaimable and pages out
quite nicely when there is memory pressure.  That's how they run 20,000
disks on the s390 boxes with no memory :)

But it would be nice to solve the issue "generically" for ram based
filesystems, if possible (usbfs, securityfs, debugfs, etc.)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
