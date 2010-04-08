Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EC793620084
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 02:19:47 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o386JiFD021958
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 8 Apr 2010 15:19:44 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7176C45DE6F
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:19:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 470AD45DE70
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:19:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 26733E18003
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:19:44 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AA5E8E1800C
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:19:40 +0900 (JST)
Date: Thu, 8 Apr 2010 15:15:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 -mmotm 0/2] memcg: move charge of file cache/shmem
Message-Id: <20100408151555.128ed6f7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100408140922.422b21b0.nishimura@mxp.nes.nec.co.jp>
References: <20100408140922.422b21b0.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Apr 2010 14:09:22 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> I updated patches for supporting move charge of file pages.
> 
> I changed the meaning of bit 1 and 2 of move_charge_at_immigrate: file pages
> including tmpfs can be moved by setting bit 1 of move_charge_at_immigrate
> regardless of the mapcount, and I don't use bit 2 anymore.
> And I added a clean up patch based on KAMEZAWA-san's one.
> 
>   [1/2] memcg: clean up move charge
>   [2/2] memcg: move charge of file pages
> 

seems much easier to read, understand. Thanks!
-Kame

> ChangeLog:
> - v2->v3
>   - based on mmotm-2010-04-05-16-09.
>   - added clean up for is_target_pte_for_mc().
>   - changed the meaning of bit 1 and 2. charges of file pages including tmpfs can
>     be moved regardless of the mapcount by setting bit 1 of move_charge_at_immigrate.
> - v1->v2
>   - updated documentation.
> 
> 
> Thanks,
> Daisuke Nishimura.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
