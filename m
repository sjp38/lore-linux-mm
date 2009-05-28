Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C567E6B0062
	for <linux-mm@kvack.org>; Thu, 28 May 2009 04:36:42 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4S8bE20024959
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 28 May 2009 17:37:14 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DBC045DE58
	for <linux-mm@kvack.org>; Thu, 28 May 2009 17:37:14 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E29E845DE52
	for <linux-mm@kvack.org>; Thu, 28 May 2009 17:37:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C7CEC1DB8062
	for <linux-mm@kvack.org>; Thu, 28 May 2009 17:37:13 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C0C31DB805B
	for <linux-mm@kvack.org>; Thu, 28 May 2009 17:37:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] remove CONFIG_UNEVICTABLE_LRU definition from defconfig
In-Reply-To: <20090528013146.6dd99aa0.akpm@linux-foundation.org>
References: <20090514111519.9B5D.A69D9226@jp.fujitsu.com> <20090528013146.6dd99aa0.akpm@linux-foundation.org>
Message-Id: <20090528173242.92E4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 28 May 2009 17:37:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

> On Thu, 14 May 2009 11:15:49 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > Subject: [PATCH] remove CONFIG_UNEVICTABLE_LRU definition from defconfig
> > 
> > Now, There isn't CONFIG_UNEVICTABLE_LRU. these line are unnecessary.
> > 
> > ...
> >
> >  196 files changed, 196 deletions(-)
> 
> Gad.
> 
> I don't know if this is worth bothering about really.  The dead Kconfig
> option will slowly die a natural death as people refresh the defconfig
> files.

ok. I'll drop this patch. 
Sorry, I did not have the experience that changed defconfig ;)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
