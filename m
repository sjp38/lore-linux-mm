Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 0CB6C6B00E1
	for <linux-mm@kvack.org>; Wed, 29 May 2013 16:45:13 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 29 May 2013 16:45:12 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 362826E804C
	for <linux-mm@kvack.org>; Wed, 29 May 2013 16:45:06 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4TKj97M288012
	for <linux-mm@kvack.org>; Wed, 29 May 2013 16:45:09 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4TKj8ho015379
	for <linux-mm@kvack.org>; Wed, 29 May 2013 16:45:09 -0400
Date: Wed, 29 May 2013 15:45:03 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCHv12 2/4] zbud: add to mm/
Message-ID: <20130529204503.GE428@cerebellum>
References: <1369067168-12291-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1369067168-12291-3-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130528145911.bd484cbb0bb7a27c1623c520@linux-foundation.org>
 <20130529154500.GB428@cerebellum>
 <20130529113434.b2ced4cc1e66c7a0a520d908@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130529113434.b2ced4cc1e66c7a0a520d908@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Wed, May 29, 2013 at 11:34:34AM -0700, Andrew Morton wrote:
> > > > +	if (size <= 0 || gfp & __GFP_HIGHMEM)
> > > > +		return -EINVAL;
> > > > +	if (size > PAGE_SIZE)
> > > > +		return -E2BIG;
> > > 
> > > Means "Argument list too long" and isn't appropriate here.
> > 
> > Ok, I need a return value other than -EINVAL to convey to the user that the
> > allocation is larger than what the allocator can hold. I don't see an existing
> > errno that would be more suited for that.  Do you have a suggestion?
> 
> ENOMEM perhaps.  That's also somewhat misleading, but I guess there's
> precedent for ENOMEM meaning "allocation too large" as well as "out
> of memory".

Ah, spoke to soon. ENOMEM is already being used to indicate that an allocation
to grow the pool failed.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
