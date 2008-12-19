Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3B8C56B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 04:39:11 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBJ9fHOn004022
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Dec 2008 18:41:17 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 01A7145DE58
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 18:41:16 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 673C245DE50
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 18:41:15 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DF621DB8046
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 18:41:15 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D2361DB8038
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 18:41:14 +0900 (JST)
Date: Fri, 19 Dec 2008 18:40:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [bug][mmtom] memcg: MEM_CGROUP_ZSTAT underflow
Message-Id: <20081219184017.7da8748e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081219182929.428380df.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081219172903.7ca9b123.nishimura@mxp.nes.nec.co.jp>
	<20081219182929.428380df.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hugh Dickins <hugh@veritas.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Dec 2008 18:29:29 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> +	/*
> + 	 * Don't clear pc->mem_cgroup because del_from_lru() will see this.
> + 	 * The fully unchaged page is assumed to be freed after us, so it's
> + 	 * safe. When this page is reused before free, we have to be careful.
> + 	 * (In SwapCache case...it can happen.)
> +  	 */
>  
Maybe this is better.
==
       /*
         * Don't clear pc->mem_cgroup because del_from_lru() may see this.
         * If this page is fully unchaged, it's assumed to be freed soon,or it
         * is isolated from LRU.  When this page is reused before free
         * (and on LRU), we have to be careful.
         * (In SwapCache case...it can happen.)
         */
==
Hmm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
