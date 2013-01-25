Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 479A86B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 16:35:11 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id bi1so492823pad.36
        for <linux-mm@kvack.org>; Fri, 25 Jan 2013 13:35:10 -0800 (PST)
Date: Fri, 25 Jan 2013 13:35:07 -0800
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCHv2 5/9] debugfs: add get/set for atomic types
Message-ID: <20130125213507.GA17700@kroah.com>
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1357590280-31535-6-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130107203219.GA19596@kroah.com>
 <50EB32FB.30802@linux.vnet.ibm.com>
 <5102B690.4090503@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5102B690.4090503@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: devel@driverdev.osuosl.org, Rik van Riel <riel@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Larry Woodman <lwoodman@redhat.com>, Nitin Gupta <ngupta@vflare.org>, Jenifer Hopper <jhopper@us.ibm.com>

On Fri, Jan 25, 2013 at 10:45:04AM -0600, Seth Jennings wrote:
> On 01/07/2013 02:41 PM, Seth Jennings wrote:
> > On 01/07/2013 02:32 PM, Greg Kroah-Hartman wrote:
> >> On Mon, Jan 07, 2013 at 02:24:36PM -0600, Seth Jennings wrote:
> >>> debugfs currently lack the ability to create attributes
> >>> that set/get atomic_t values.
> >>
> >> I hate to ask, but why would you ever want to do such a thing?
> > 
> > There are a few atomic_t statistics in zswap that are valuable to have
> > in the debugfs attributes.  Rather than have non-atomic mirrors of all
> > of them, as is done in zcache right now (see
> > drivers/staging/ramster/zcache-main.c:131), I thought this to be a
> > cleaner solution.
> > 
> > Granted, I personally have no use for the setting part; only the
> > getting part.  I only included the setting operations to keep the
> > balance and conform with the rest of the debugfs implementation.
> 
> Greg, I never did get your ack or rejection here.  Are you ok with
> this patch?

Some patches you just hold your breath and hope the sender goes away and
never asks about again, this was one of them :)

Seriously, it's fine, feel free to take it through whatever tree it
depends on.

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
