Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B853B6B00E5
	for <linux-mm@kvack.org>; Wed, 13 May 2009 06:36:53 -0400 (EDT)
Subject: Re: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED
 submenu
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <20090513191221.674bc543.minchan.kim@barrios-desktop>
References: <20090513172904.7234.A69D9226@jp.fujitsu.com>
	 <20090513175152.1590c117.minchan.kim@barrios-desktop>
	 <20090513175539.723A.A69D9226@jp.fujitsu.com>
	 <20090513191221.674bc543.minchan.kim@barrios-desktop>
Content-Type: text/plain
Date: Wed, 13 May 2009 11:37:17 +0100
Message-Id: <1242211037.24436.552.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-05-13 at 19:12 +0900, Minchan Kim wrote:
> > No.
> > As far as I know, many embedded guys use this configuration.
> > they hate unexpected latency by reclaim. !UNEVICTABLE_LRU increase
> > unexpectability largely.
> 
> As I said previous(http://lkml.org/lkml/2009/3/16/209), Many embedded
> environment have a small ram. It doesn't have a big impact in such
> case. 
> 
> Let CCed embedded matainers. 
> I won't have a objection if embedded maintainers ack this. 

I probably wouldn't be cheerleading for it if you wanted to make it
optional when it wasn't before -- but I suppose we might as well
preserve the option under CONFIG_EMBEDDED if the alternative is to lose
it completely.

Acked-by: David Woodhouse <David.Woodhouse@intel.com>

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
