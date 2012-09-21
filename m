Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 921946B0072
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 14:13:39 -0400 (EDT)
Date: Fri, 21 Sep 2012 14:02:22 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC] mm: add support for zsmalloc and zcache
Message-ID: <20120921180222.GA7220@phenom.dumpdata.com>
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120921161252.GV11266@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120921161252.GV11266@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Fri, Sep 21, 2012 at 05:12:52PM +0100, Mel Gorman wrote:
> On Tue, Sep 04, 2012 at 04:34:46PM -0500, Seth Jennings wrote:
> > zcache is the remaining piece of code required to support in-kernel
> > memory compression.  The other two features, cleancache and frontswap,
> > have been promoted to mainline in 3.0 and 3.5 respectively.  This
> > patchset promotes zcache from the staging tree to mainline.
> > 
> 
> This is a very rough review of the code simply because I was asked to
> look at it. I'm barely aware of the history and I'm not a user of this
> code myself so take all of this with a grain of salt.

Ah fresh set of eyes! Yeey!
> 
> Very broadly speaking my initial reaction before I reviewed anything was
> that *some* sort of usable backend for cleancache or frontswap should exist
> at this point. My understanding is that Xen is the primary user of both
> those frontends and ramster, while interesting, is not something that a
> typical user will benefit from.

Right, the majority of users do not use virtualization. Thought embedded
wise .. well, there are a lot of Android users - thought I am not 100%
sure they are using it right now (I recall seeing changelogs for the clones
of Android mentioning zcache).
> 
> That said, I worry that this has bounced around a lot and as Dan (the
> original author) has a rewrite. I'm wary of spending too much time on this
> at all. Is Dan's new code going to replace this or what? It'd be nice to
> find a definitive answer on that.

The idea is to take parts of zcache2 as seperate patches and stick it
in the code you just reviewed (those that make sense as part of unstaging).
The end result will be that zcache1 == zcache2 in functionality. Right
now we are assembling a list of TODOs for zcache that should be done as part
of 'unstaging'.

> 
> Anyway, here goes

.. and your responses will fill the TODO with many extra line-items.

Its going to take a bit of time to mull over your questions, so it will
take me some time. Also Dan will probably beat me in providing the answers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
