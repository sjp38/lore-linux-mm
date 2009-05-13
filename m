Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 799616B00D1
	for <linux-mm@kvack.org>; Wed, 13 May 2009 04:58:43 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4D8xal0020371
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 May 2009 17:59:36 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 611FA45DD7C
	for <linux-mm@kvack.org>; Wed, 13 May 2009 17:59:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 338C545DD74
	for <linux-mm@kvack.org>; Wed, 13 May 2009 17:59:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 165091DB8019
	for <linux-mm@kvack.org>; Wed, 13 May 2009 17:59:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BD6DD1DB8015
	for <linux-mm@kvack.org>; Wed, 13 May 2009 17:59:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED submenu
In-Reply-To: <20090513175152.1590c117.minchan.kim@barrios-desktop>
References: <20090513172904.7234.A69D9226@jp.fujitsu.com> <20090513175152.1590c117.minchan.kim@barrios-desktop>
Message-Id: <20090513175539.723A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 May 2009 17:59:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> Hi, Kosaki. 
> 
> On Wed, 13 May 2009 17:30:45 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > Subject: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED submenu
> > 
> > Almost people always turn on CONFIG_UNEVICTABLE_LRU. this configuration is
> > used only embedded people.
> 
> I think at least embedded guys don't need it. 
> But I am not sure other guys. 

perhaps, I and you live in another embedded world.


> > +config UNEVICTABLE_LRU
> > +	bool "Add LRU list to track non-evictable pages" if EMBEDDED
> > +	default y
> 
> If you want to move, it would be better as following.
> 
> config UNEVICTABLE_LRU
>        bool "Add LRU list to track non-evictable pages" if EMBEDDED
>        default !EMBEDDED

No.
As far as I know, many embedded guys use this configuration.

they hate unexpected latency by reclaim. !UNEVICTABLE_LRU increase
unexpectability largely.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
