Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 399226B013B
	for <linux-mm@kvack.org>; Wed, 13 May 2009 19:17:08 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4DNHJW4021241
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 May 2009 08:17:21 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B6BB45DE51
	for <linux-mm@kvack.org>; Thu, 14 May 2009 08:17:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D3E745DE4F
	for <linux-mm@kvack.org>; Thu, 14 May 2009 08:17:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 031781DB8038
	for <linux-mm@kvack.org>; Thu, 14 May 2009 08:17:19 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AF67E08003
	for <linux-mm@kvack.org>; Thu, 14 May 2009 08:17:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED submenu
In-Reply-To: <20090513141335.GS19296@one.firstfloor.org>
References: <2f11576a0905130458x2e56e952ga47216da42b30906@mail.gmail.com> <20090513141335.GS19296@one.firstfloor.org>
Message-Id: <20090514080200.1E24.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 May 2009 08:17:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Minchan@firstfloor.org
List-ID: <linux-mm.kvack.org>

> > 1. this featuren don't depend CONFIG_MMU. that's bogus.
> 
> Without CONFIG_MMU everything is unevictable, so you don't need
> to special case unevictable pages.  Or are you saying it should
> use this code always?

Ah, I misparsed your messages.
I talked as the code is independent, but you talked worth is little.
hm, I think both are right.

Anyway, Minchan acked to remvoe config option, I'll do that.
Thanks.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
