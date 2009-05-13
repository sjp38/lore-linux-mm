Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DF04A6B00E9
	for <linux-mm@kvack.org>; Wed, 13 May 2009 07:13:59 -0400 (EDT)
Received: by pxi37 with SMTP id 37so237396pxi.12
        for <linux-mm@kvack.org>; Wed, 13 May 2009 04:14:11 -0700 (PDT)
Date: Wed, 13 May 2009 20:13:49 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED
 submenu
Message-Id: <20090513201349.a90a9d46.minchan.kim@barrios-desktop>
In-Reply-To: <1242211037.24436.552.camel@macbook.infradead.org>
References: <20090513172904.7234.A69D9226@jp.fujitsu.com>
	<20090513175152.1590c117.minchan.kim@barrios-desktop>
	<20090513175539.723A.A69D9226@jp.fujitsu.com>
	<20090513191221.674bc543.minchan.kim@barrios-desktop>
	<1242211037.24436.552.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Woodhouse <dwmw2@infradead.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Wed, 13 May 2009 11:37:17 +0100
David Woodhouse <dwmw2@infradead.org> wrote:

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

Thanks for good commeting.
If embedded maintainer don't have an obejction, me, too. :)

But Let's add following comment like CONFIG_AIO. 

"Disabling this option saves about 7k"

> 
> Acked-by: David Woodhouse <David.Woodhouse@intel.com>
> 
> -- 
> David Woodhouse                            Open Source Technology Centre
> David.Woodhouse@intel.com                              Intel Corporation
> 


-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
