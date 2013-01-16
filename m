Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 0674D6B006C
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 12:47:43 -0500 (EST)
Date: Wed, 16 Jan 2013 12:47:36 -0500
From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all
 dma_alloc_coherent() calls
Message-ID: <20130116174736.GJ25500@titan.lakedaemon.net>
References: <50F3F289.3090402@web.de>
 <20130115165642.GA25500@titan.lakedaemon.net>
 <20130115175020.GA3764@kroah.com>
 <20130115201617.GC25500@titan.lakedaemon.net>
 <20130115215602.GF25500@titan.lakedaemon.net>
 <50F5F1B7.3040201@web.de>
 <20130116024014.GH25500@titan.lakedaemon.net>
 <50F61D86.4020801@web.de>
 <50F66B1B.40301@web.de>
 <50F6E419.5080007@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50F6E419.5080007@web.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Soeren Moch <smoch@web.de>
Cc: Greg KH <gregkh@linuxfoundation.org>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

On Wed, Jan 16, 2013 at 06:32:09PM +0100, Soeren Moch wrote:
> On 16.01.2013 09:55, Soeren Moch wrote:
> >On 16.01.2013 04:24, Soeren Moch wrote:
> >>I did not bisect it, but Marek mentioned earlier that commit
> >>e9da6e9905e639b0f842a244bc770b48ad0523e9 in Linux v3.6-rc1 introduced
> >>new code for dma allocations. This is probably the root cause for the
> >>new (mis-)behavior (due to my tests 3.6.0 is not working anymore).
> >
> >I don't want to say that Mareks patch is wrong, probably it triggers a
> >bug somewhere else! (in em28xx?)
> 
> The em28xx sticks are using isochronous usb transfers. Is there a
> special handling for that?

I'm looking at that now.  It looks like the em28xx wants (as a maximum)
655040 bytes (em28xx-core.c:1088).  There are 5 transfer buffers, with
64 max packets and 2047 max packet size (runtime reported max & 0x7ff).

If it actually needs all of that, then the answer may be to just
increase coherent_pool= when using that driver.  I'll keep digging.

thx,

Jason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
