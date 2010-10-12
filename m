Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D84DD6B00AD
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 01:07:29 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9C57Oss014193
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 12 Oct 2010 14:07:25 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9779745DE54
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 14:07:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C2C245DE50
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 14:07:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 407B2E08001
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 14:07:24 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D028C1DB8048
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 14:07:23 +0900 (JST)
Date: Tue, 12 Oct 2010 14:01:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2] memcg: reduce lock time at move charge (Was Re:
 [PATCH 04/10] memcg: disable local interrupts in lock_page_cgroup()
Message-Id: <20101012140151.767fbba6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101012125613.1accc1bd.nishimura@mxp.nes.nec.co.jp>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<20101005160332.GB9515@barrios-desktop>
	<xr93wrpwkypv.fsf@ninji.mtv.corp.google.com>
	<AANLkTikKXNx-Cj2UY+tJj8ifC+Je5WDbS=eR6xsKM1uU@mail.gmail.com>
	<20101007093545.429fe04a.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007105456.d86d8092.nishimura@mxp.nes.nec.co.jp>
	<20101007111743.322c3993.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007152111.df687a62.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007162811.c3a35be9.nishimura@mxp.nes.nec.co.jp>
	<20101007164204.83b207c6.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007170405.27ed964c.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007161454.84570cf9.akpm@linux-foundation.org>
	<20101008133712.2a836331.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007215556.21412ae6.akpm@linux-foundation.org>
	<20101008141201.c1e3a4e2.kamezawa.hiroyu@jp.fujitsu.com>
	<20101008194131.20b44a9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20101012125613.1accc1bd.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Oct 2010 12:56:13 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > +err_out:
> > +	for (; mt < info + num; mt++)
> > +		if (mt->type == MC_TARGET_PAGE) {
> > +			putback_lru_page(mt->val.page);
> Is this putback_lru_page() necessary ?
> is_target_pte_for_mc() doesn't isolate the page.
> 
Unnecessary, will post v2.

I'm sorry for my low-quality patches :(

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
