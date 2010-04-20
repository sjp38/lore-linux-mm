Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 70F356B01F4
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 00:30:29 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3K4UEuR009178
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 20 Apr 2010 13:30:14 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D1C545DE51
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 13:30:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 206F545DE4F
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 13:30:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F0CFE1DB803C
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 13:30:13 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AFB81DB8037
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 13:30:13 +0900 (JST)
Date: Tue, 20 Apr 2010 13:26:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][BUGFIX][PATCH 2/2] memcg: fix file mapped underflow at
 migration (v3)
Message-Id: <20100420132616.ed27f757.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100420132050.3477a717.nishimura@mxp.nes.nec.co.jp>
References: <20100413134207.f12cdc9c.nishimura@mxp.nes.nec.co.jp>
	<20100415120516.3891ce46.kamezawa.hiroyu@jp.fujitsu.com>
	<20100415120652.c577846f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100416193143.5807d114.kamezawa.hiroyu@jp.fujitsu.com>
	<20100419124225.91f3110b.nishimura@mxp.nes.nec.co.jp>
	<20100419131817.f263d93c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100419170701.3864992e.nishimura@mxp.nes.nec.co.jp>
	<20100419172629.dbf65e18.kamezawa.hiroyu@jp.fujitsu.com>
	<20100420132050.3477a717.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 20 Apr 2010 13:20:50 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > > I have one concern for now. Reading the patch, the flag have influence on
> > > only anonymous pages, so we'd better to note it and I feel it strange to
> > > set(and clear) the flag of "old page" always(iow, even when !PageAnon)
> > > in prepare_migration.
> > > 
> > 
> > Hmm...Checking "Only Anon" is simpler ?
> I just thought it was inconsistent that we always set/clear the bit about "old page",
> while we set the bit about "new page" only in PageAnon case.
> 
Ok, look into again.


> > It will have no meanings for migrating
> > file caches, but it may have some meanings for easy debugging. 
> > I think "mark it always but it's used only for anonymous page" is reasonable
> > (if it causes no bug.)
> > 
> Anyway, I don't have any strong objection.
> It's all right for me as long as it is well documented or commented.
> 
Maybe I can post v4, today.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
