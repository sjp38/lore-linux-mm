Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7D980600373
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 02:36:00 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o386ZveE028883
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 8 Apr 2010 15:35:58 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 656A245DE60
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:35:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3459045DE4D
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:35:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E94EBE18004
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:35:56 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 66B81E1800C
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:35:53 +0900 (JST)
Date: Thu, 8 Apr 2010 15:32:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 -mmotm 1/2] memcg: clean up move charge
Message-Id: <20100408153207.6dafa26c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100408141020.47535e5e.nishimura@mxp.nes.nec.co.jp>
References: <20100408140922.422b21b0.nishimura@mxp.nes.nec.co.jp>
	<20100408141020.47535e5e.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Apr 2010 14:10:20 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This patch cleans up move charge code by:
> 
> - define functions to handle pte for each types, and make is_target_pte_for_mc()
>   cleaner.
> - instead of checking the MOVE_CHARGE_TYPE_ANON bit, define a function that
>   checks the bit.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
