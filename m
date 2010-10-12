Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB646B00B3
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 02:25:08 -0400 (EDT)
Date: Tue, 12 Oct 2010 15:23:42 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH v4] memcg: reduce lock time at move charge
Message-Id: <20101012152342.c5b489e4.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101012144801.51d15a02.kamezawa.hiroyu@jp.fujitsu.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
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
	<20101012144801.51d15a02.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Oct 2010 14:48:01 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 12 Oct 2010 12:56:13 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > > +err_out:
> > > +	for (; mt < info + num; mt++)
> > > +		if (mt->type == MC_TARGET_PAGE) {
> > > +			putback_lru_page(mt->val.page);
> > Is this putback_lru_page() necessary ?
> > is_target_pte_for_mc() doesn't isolate the page.
> > 
> Ok, v4 here. tested failure path and success path.
> 
Looks good to me.

	Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
