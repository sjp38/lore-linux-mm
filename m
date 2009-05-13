Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2FE8E6B010A
	for <linux-mm@kvack.org>; Wed, 13 May 2009 10:33:56 -0400 (EDT)
Date: Wed, 13 May 2009 09:34:00 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED submenu
Message-ID: <20090513143400.GC31071@waste.org>
References: <20090513172904.7234.A69D9226@jp.fujitsu.com> <20090513175152.1590c117.minchan.kim@barrios-desktop> <20090513175539.723A.A69D9226@jp.fujitsu.com> <20090513191221.674bc543.minchan.kim@barrios-desktop> <1242211037.24436.552.camel@macbook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1242211037.24436.552.camel@macbook.infradead.org>
Sender: owner-linux-mm@kvack.org
To: David Woodhouse <dwmw2@infradead.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 13, 2009 at 11:37:17AM +0100, David Woodhouse wrote:
> On Wed, 2009-05-13 at 19:12 +0900, Minchan Kim wrote:
> > > No.
> > > As far as I know, many embedded guys use this configuration.
> > > they hate unexpected latency by reclaim. !UNEVICTABLE_LRU increase
> > > unexpectability largely.
> > 
> > As I said previous(http://lkml.org/lkml/2009/3/16/209), Many embedded
> > environment have a small ram. It doesn't have a big impact in such
> > case. 
> > 
> > Let CCed embedded matainers. 
> > I won't have a objection if embedded maintainers ack this. 
> 
> I probably wouldn't be cheerleading for it if you wanted to make it
> optional when it wasn't before -- but I suppose we might as well
> preserve the option under CONFIG_EMBEDDED if the alternative is to lose
> it completely.

As the person who introduced CONFIG_EMBEDDED, I've occasionally
thought we should rename it to CONFIG_NONSTANDARD to make the
semantics clearer. It's less about cell phones and more about going
way off the beaten path.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
