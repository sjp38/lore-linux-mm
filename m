Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id C45366B0005
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 23:32:17 -0500 (EST)
Date: Wed, 30 Jan 2013 13:32:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv4 0/7] zswap: compressed swap caching
Message-ID: <20130130043214.GC2580@blaptop>
References: <1359495627-30285-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1359497685.16868.11.camel@joe-AO722>
 <510851E0.8000009@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <510851E0.8000009@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Tue, Jan 29, 2013 at 04:49:04PM -0600, Seth Jennings wrote:
> On 01/29/2013 04:14 PM, Joe Perches wrote:
> > On Tue, 2013-01-29 at 15:40 -0600, Seth Jennings wrote:
> >> The code required for the flushing is in a separate patch now
> >> as requested.
> > 
> > What tree does this apply to?
> > Both -next and linus fail to compile.
> 
> Link to build instruction in the cover letter:
> 
> >> NOTE: To build, read this:
> >> http://lkml.org/lkml/2013/1/28/586
> 
> The complexity is due to a conflict with a zsmalloc patch in Greg's
> staging tree that has yet to make its way upstream.
> 
> Sorry for the inconvenience.

Seth, Please don't ignore previous review if you didn't convince reviewer.
I don't want to consume time with arguing trivial things.

Copy and Paste from previous discussion from zsmalloc pathset

> > > On Fri, Jan 25, 2013 at 11:46:14AM -0600, Seth Jennings wrote:
> > >> These patches are the first 4 patches of the zswap patchset I
> > >> sent out previously.  Some recent commits to zsmalloc and
> > >> zcache in staging-next forced a rebase. While I was at it, Nitin
> > >> (zsmalloc maintainer) requested I break these 4 patches out from
> > >> the zswap patchset, since they stand on their own.
> > > 
> > > [2/4] and [4/4] is okay to merge current zsmalloc in staging but
> > > [1/4] and [3/4] is dependent on zswap so it should be part of
> > > zswap patchset.
> > 
> > Just to clarify, patches 1 and 3 are _not_ dependent on zswap.  They
> > just introduce changes that are only needed by zswap.
> 
> I don't think so. If zswap might be not merged, we don't need [1, 3]
> at the moment. You could argue that [1, 3] make zsmalloc more flexible
> and I agree. BUT I want it when we have needs. It would be not too late.
> So [1,3] should be part of zswap patchset.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
