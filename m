Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 681E16B0002
	for <linux-mm@kvack.org>; Sun,  3 Feb 2013 20:03:42 -0500 (EST)
Received: by mail-ie0-f176.google.com with SMTP id k13so3358007iea.21
        for <linux-mm@kvack.org>; Sun, 03 Feb 2013 17:03:41 -0800 (PST)
Message-ID: <1359939818.9366.1.camel@kernel.cn.ibm.com>
Subject: Re: [PATCHv4 0/7] zswap: compressed swap caching
From: Simon Jeons <simon.jeons@gmail.com>
Date: Sun, 03 Feb 2013 19:03:38 -0600
In-Reply-To: <510BDB8F.5000104@linux.vnet.ibm.com>
References: <1359495627-30285-1-git-send-email-sjenning@linux.vnet.ibm.com>
	 <1359682784.3574.2.camel@kernel> <510BDB8F.5000104@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Fri, 2013-02-01 at 09:13 -0600, Seth Jennings wrote:
> On 01/31/2013 07:39 PM, Simon Jeons wrote:
> > Hi Seth,
> > On Tue, 2013-01-29 at 15:40 -0600, Seth Jennings wrote:
> <snip>
> >> Performance, Kernel Building:
> >>
> >> Setup
> >> ========
> >> Gentoo w/ kernel v3.7-rc7
> >> Quad-core i5-2500 @ 3.3GHz
> >> 512MB DDR3 1600MHz (limited with mem=512m on boot)
> >> Filesystem and swap on 80GB HDD (about 58MB/s with hdparm -t)
> >> majflt are major page faults reported by the time command
> >> pswpin/out is the delta of pswpin/out from /proc/vmstat before and after
> >> then make -jN
> >>
> >> Summary
> >> ========
> >> * Zswap reduces I/O and improves performance at all swap pressure levels.
> >>
> >> * Under heavy swaping at 24 threads, zswap reduced I/O by 76%, saving
> >>   over 1.5GB of I/O, and cut runtime in half.
> > 
> > How to get your benchmark?
> 
> It's just kernel building.  So "make" :)
> 
> I intentionally choose this workload so people wouldn't have to jump
> through hoops to replicate the results.

Since there already have zram which can handle anonymous pages
compression, why need zswap? What's the difference of design between
zram and zswap? 

> 
> Seth
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
