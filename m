Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1D17E6B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 22:48:26 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6D38F2s010303
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 13 Jul 2009 12:08:15 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B3B145DE50
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 12:08:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CBB745DE4F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 12:08:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 329B2E08001
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 12:08:15 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E0FF41DB8040
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 12:08:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] switch free memory back to MIGRATE_MOVABLE
In-Reply-To: <20090713030444.GA2582@sli10-desk.sh.intel.com>
References: <20090713115803.b78a4f4f.kamezawa.hiroyu@jp.fujitsu.com> <20090713030444.GA2582@sli10-desk.sh.intel.com>
Message-Id: <20090713120549.6252.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 13 Jul 2009 12:08:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

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

This answer is not actual answer.
Why do you think __rmqueue_fallback() doesn't works well? Do you have
any test-case or found a bug by review?





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
