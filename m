Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5183D6B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 22:40:04 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6D2xpQV005936
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 13 Jul 2009 11:59:51 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8172445DE4F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 11:59:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F86245DE4E
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 11:59:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 080251DB803F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 11:59:50 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B3D72E38001
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 11:59:49 +0900 (JST)
Date: Mon, 13 Jul 2009 11:58:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] switch free memory back to MIGRATE_MOVABLE
Message-Id: <20090713115803.b78a4f4f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090713113326.624F.A69D9226@jp.fujitsu.com>
References: <20090713023030.GA27269@sli10-desk.sh.intel.com>
	<20090713113326.624F.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 Jul 2009 11:47:46 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > When page is back to buddy and its order is bigger than pageblock_order, we can
> > switch its type to MIGRATE_MOVABLE. This can reduce fragmentation. The patch
> > has obvious effect when read a block device and then drop caches.
> > 
> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> 
> This patch change hot path, but there is no performance mesurement description.
> Also, I don't like modification buddy core for only drop caches.
> 
Li, does this patch imply fallback of migration type doesn't work well ?
What is the bad case ?

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
