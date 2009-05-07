Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 608F76B0047
	for <linux-mm@kvack.org>; Wed,  6 May 2009 22:46:32 -0400 (EDT)
Date: Thu, 7 May 2009 10:46:56 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/7] proc: export more page flags in /proc/kpageflags
Message-ID: <20090507024656.GA12828@localhost>
References: <20090507012116.996644836@intel.com> <20090507014914.364045992@intel.com> <20090507114016.40ee6577.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090507114016.40ee6577.minchan.kim@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 07, 2009 at 10:40:16AM +0800, Minchan Kim wrote:
> On Thu, 07 May 2009 09:21:21 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > +	 * pseudo flags for the well known (anonymous) memory mapped pages
> > +	 */
> > +	if (!PageSlab(page) && page_mapped(page))
> > +		u |= 1 << KPF_MMAP;
> > +	if (PageAnon(page))
> > +		u |= 1 << KPF_ANON;
> 
> Why do you check PageSlab on user pages ?
> Is there any case that PageSlab == true && page_mapped == true ?

Yes at least for SLUB: it reuses page->_mapcount, so page_mapped() is
meaningless for slab pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
