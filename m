Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8229E6B00E4
	for <linux-mm@kvack.org>; Wed, 13 May 2009 06:12:26 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id v27so193810wah.22
        for <linux-mm@kvack.org>; Wed, 13 May 2009 03:12:36 -0700 (PDT)
Date: Wed, 13 May 2009 19:12:21 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED
 submenu
Message-Id: <20090513191221.674bc543.minchan.kim@barrios-desktop>
In-Reply-To: <20090513175539.723A.A69D9226@jp.fujitsu.com>
References: <20090513172904.7234.A69D9226@jp.fujitsu.com>
	<20090513175152.1590c117.minchan.kim@barrios-desktop>
	<20090513175539.723A.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Matt Mackall <mpm@selenic.com>, David Woodhouse <dwmw2@infradead.org>
List-ID: <linux-mm.kvack.org>

On Wed, 13 May 2009 17:59:34 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > Hi, Kosaki. 
> > 
> > On Wed, 13 May 2009 17:30:45 +0900 (JST)
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > Subject: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED submenu
> > > 
> > > Almost people always turn on CONFIG_UNEVICTABLE_LRU. this configuration is
> > > used only embedded people.
> > 
> > I think at least embedded guys don't need it. 
> > But I am not sure other guys. 
> 
> perhaps, I and you live in another embedded world.


Each people always have a different viewpoint. 
:) 

> 
> > > +config UNEVICTABLE_LRU
> > > +	bool "Add LRU list to track non-evictable pages" if EMBEDDED
> > > +	default y
> > 
> > If you want to move, it would be better as following.
> > 
> > config UNEVICTABLE_LRU
> >        bool "Add LRU list to track non-evictable pages" if EMBEDDED
> >        default !EMBEDDED
> 
> No.
> As far as I know, many embedded guys use this configuration.
> they hate unexpected latency by reclaim. !UNEVICTABLE_LRU increase
> unexpectability largely.

As I said previous(http://lkml.org/lkml/2009/3/16/209), Many embedded environment have a small ram. It doesn't have a big impact in such case. 

Let CCed embedded matainers. 
I won't have a objection if embedded maintainers ack this. 

Thanks for your effort for embdded. 

-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
