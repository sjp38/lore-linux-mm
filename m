Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id E3E3E6B004D
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 18:48:56 -0400 (EDT)
Date: Wed, 25 Jul 2012 23:48:52 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/34] Memory management performance backports for
 -stable V2
Message-ID: <20120725224852.GF9222@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
 <20120725223057.GA4253@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120725223057.GA4253@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Stable <stable@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 25, 2012 at 03:30:57PM -0700, Greg KH wrote:
> > <SNIP>
> > All of the patches will apply to 3.0-stable but the ordering of the
> > patches is such that applying them to 3.2-stable and 3.4-stable should
> > be straight-forward.
> 
> I can't find any of these that should have gone to 3.4-stable, given
> that they all were included in 3.4 already, right?
> 

Yes, you're right.

At the time I wrote the changelog I had patches belonging to 3.5 included. I
later decided to drop them until after 3.5 was out. It was potentially
weird to have a 3.0-stable kernel with patches that were not in a released
3.x.0 kernel. Besides, they were very low priority. I forgot to update
the changelog to match.

> I've queued up the whole lot for the 3.0-stable tree, thanks so much for
> providing them.
> 

Thanks for reviewing them in detail and getting the flaws corrected.
I expect it'll be a bit more smooth if/when I do something like this again.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
