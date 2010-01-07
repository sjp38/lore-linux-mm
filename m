Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C50526B00B9
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 00:55:38 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o075tZWh017903
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Jan 2010 14:55:36 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6512645DE50
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 14:55:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 396BE45DE4D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 14:55:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E3C41DB803F
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 14:55:35 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AE6111DB8041
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 14:55:34 +0900 (JST)
Date: Thu, 7 Jan 2010 14:52:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm] build fix for
 memcg-move-charges-of-anonymous-swap.patch
Message-Id: <20100107145223.a73e2be9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100107141401.6a182085.nishimura@mxp.nes.nec.co.jp>
References: <201001062259.o06MxQrp023236@imap1.linux-foundation.org>
	<20100106171058.f1d6f393.randy.dunlap@oracle.com>
	<20100107111319.7d95fe86.nishimura@mxp.nes.nec.co.jp>
	<20100107112150.2e585f1c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107115901.594330d0.nishimura@mxp.nes.nec.co.jp>
	<20100107120233.f244d4b7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107130609.31fe83dc.nishimura@mxp.nes.nec.co.jp>
	<20100107133026.6350bd9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107141401.6a182085.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 2010 14:14:01 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Anyway, I'm sorry that the first patch was wrong...
> This is the correct one.
> 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> build fix in !CONFIG_SWAP case.
> 
>   CC      mm/memcontrol.o
> mm/memcontrol.c: In function 'is_target_pte_for_mc':
> mm/memcontrol.c:3648: error: implicit declaration of function 'mem_cgroup_count_swap_user'
> make[1]: *** [mm/memcontrol.o] Error 1
> make: *** [mm] Error 2
> 
> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thank you.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

BTW, maybe it's time to
  - remove EXPERIMENTAL from CONFIG_CGROUP_MEM_RES_CTRL_SWAP
and more,
  - remove CONFIG_CGROUP_MEM_RES_CTRL_SWAP
    (to reduce complicated #ifdefs and replace them with CONFIG_SWAP.)

It's very stable as far as I test.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
