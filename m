Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 283276B0055
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 22:49:12 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6D3920w009772
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 13 Jul 2009 12:09:03 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BD74345DD75
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 12:09:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C9F045DE5D
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 12:09:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 78FF2E38002
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 12:09:02 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F1032E38004
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 12:09:01 +0900 (JST)
Date: Mon, 13 Jul 2009 12:07:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] switch free memory back to MIGRATE_MOVABLE
Message-Id: <20090713120716.cd58a9f7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090713030444.GA2582@sli10-desk.sh.intel.com>
References: <20090713023030.GA27269@sli10-desk.sh.intel.com>
	<20090713113326.624F.A69D9226@jp.fujitsu.com>
	<20090713115803.b78a4f4f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090713030444.GA2582@sli10-desk.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 13 Jul 2009 11:04:44 +0800
Shaohua Li <shaohua.li@intel.com> wrote:

> On Mon, Jul 13, 2009 at 10:58:03AM +0800, KAMEZAWA Hiroyuki wrote:
> > On Mon, 13 Jul 2009 11:47:46 +0900 (JST)
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > > When page is back to buddy and its order is bigger than pageblock_order, we can
> > > > switch its type to MIGRATE_MOVABLE. This can reduce fragmentation. The patch
> > > > has obvious effect when read a block device and then drop caches.
> > > > 
> > > > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > > 
> > > This patch change hot path, but there is no performance mesurement description.
> > > Also, I don't like modification buddy core for only drop caches.
> > > 
> > Li, does this patch imply fallback of migration type doesn't work well ?
> > What is the bad case ?
> The page is initialized as migrate_movable, and then switch to reclaimable or
> something else when fallback occurs, but its type remains even the page gets
> freed. When the page gets freed, its type actually can be switch back to movable,
> this is what the patch does.
> 
Then, what is the benefits ? Changing this Movable here is better than fallback and
find this chunk again in lazy way ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
