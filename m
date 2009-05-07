Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D6F266B004D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 22:48:13 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n472mvQE026672
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 7 May 2009 11:48:58 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AE31945DE4E
	for <linux-mm@kvack.org>; Thu,  7 May 2009 11:48:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 760E345DE52
	for <linux-mm@kvack.org>; Thu,  7 May 2009 11:48:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 59B4B1DB8041
	for <linux-mm@kvack.org>; Thu,  7 May 2009 11:48:57 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CDD5B1DB803C
	for <linux-mm@kvack.org>; Thu,  7 May 2009 11:48:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/7] proc: export more page flags in /proc/kpageflags
In-Reply-To: <20090507024656.GA12828@localhost>
References: <20090507114016.40ee6577.minchan.kim@barrios-desktop> <20090507024656.GA12828@localhost>
Message-Id: <20090507114804.2666.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  7 May 2009 11:48:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Thu, May 07, 2009 at 10:40:16AM +0800, Minchan Kim wrote:
> > On Thu, 07 May 2009 09:21:21 +0800
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > +	 * pseudo flags for the well known (anonymous) memory mapped pages
> > > +	 */
> > > +	if (!PageSlab(page) && page_mapped(page))
> > > +		u |= 1 << KPF_MMAP;
> > > +	if (PageAnon(page))
> > > +		u |= 1 << KPF_ANON;
> > 
> > Why do you check PageSlab on user pages ?
> > Is there any case that PageSlab == true && page_mapped == true ?
> 
> Yes at least for SLUB: it reuses page->_mapcount, so page_mapped() is
> meaningless for slab pages.

this question and answer implies more comment required...



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
