Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB37o4WN024503
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Dec 2008 16:50:04 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7795945DE55
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 16:50:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D62745DE51
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 16:50:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3165EE18003
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 16:50:04 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DD28A1DB8040
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 16:50:03 +0900 (JST)
Date: Wed, 3 Dec 2008 16:49:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mmotm][PATCH 0/4] request for patch replacement
Message-Id: <20081203164914.88b2a0fa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081202131723.806f1724.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081202131723.806f1724.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh@veritas.com" <hugh@veritas.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Dec 2008 13:17:23 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Hi, I'm sorry for asking this.
> 
> please drop memcg-fix-gfp_mask-of-callers-of-charge.patch.
> 
> It got NACK. http://marc.info/?l=linux-kernel&m=122817796729117&w=2
> 
Please ignore this. memcg-revert-gfp-mask-fix.patch does all necessary fixes.

Sorry,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
