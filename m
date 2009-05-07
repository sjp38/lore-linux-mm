Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2FC396B0055
	for <linux-mm@kvack.org>; Wed,  6 May 2009 23:05:42 -0400 (EDT)
Date: Thu, 7 May 2009 11:05:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/7] proc: export more page flags in /proc/kpageflags
Message-ID: <20090507030516.GA12763@localhost>
References: <20090507114016.40ee6577.minchan.kim@barrios-desktop> <20090507024656.GA12828@localhost> <20090507114804.2666.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090507114804.2666.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 07, 2009 at 10:48:55AM +0800, KOSAKI Motohiro wrote:
> > On Thu, May 07, 2009 at 10:40:16AM +0800, Minchan Kim wrote:
> > > On Thu, 07 May 2009 09:21:21 +0800
> > > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > 
> > > > +	 * pseudo flags for the well known (anonymous) memory mapped pages
> > > > +	 */
> > > > +	if (!PageSlab(page) && page_mapped(page))
> > > > +		u |= 1 << KPF_MMAP;
> > > > +	if (PageAnon(page))
> > > > +		u |= 1 << KPF_ANON;
> > > 
> > > Why do you check PageSlab on user pages ?
> > > Is there any case that PageSlab == true && page_mapped == true ?
> > 
> > Yes at least for SLUB: it reuses page->_mapcount, so page_mapped() is
> > meaningless for slab pages.
> 
> this question and answer implies more comment required...

Good point. Updated comment to:

        /*
         * pseudo flags for the well known (anonymous) memory mapped pages
         *
         * Note that page->_mapcount is overloaded in SLOB/SLUB/SLQB, so the
         * simple test in page_mapped() is not enough.
         */
        if (!PageSlab(page) && page_mapped(page))
                u |= 1 << KPF_MMAP;


Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
