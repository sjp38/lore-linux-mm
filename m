Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 352716B0055
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 23:50:29 -0400 (EDT)
Date: Tue, 28 Apr 2009 12:49:45 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] fix leak of swap accounting as stale swap cache under
 memcg
Message-Id: <20090428124945.04a47539.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <isapiwc.d5d1bc3c.6e29.49f6574a.db2ee.65@mail.jp.nec.com>
References: <20090427181259.6efec90b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090427210856.d5f4109e.d-nishimura@mtf.biglobe.ne.jp>
	<20090428091902.fc44efbc.kamezawa.hiroyu@jp.fujitsu.com>
	<isapiwc.d5d1bc3c.6e29.49f6574a.db2ee.65@mail.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

> >> And I don't think it's a good idea to add memcg_stale_swap_congestion() here.
> >> This means less possibility to reclaim pages.
> >> 
> > Hmm. maybe adding congestion_wait() ?
> > 
> I don't think no hook before add_to_swap() is needed.
> 
s/don't//

Sorry for my poor English.

Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
