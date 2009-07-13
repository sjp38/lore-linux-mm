Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 06E226B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 21:31:06 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6D1oUO6015987
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 13 Jul 2009 10:50:30 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9891545DE5F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 10:50:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E41C45DE56
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 10:50:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A53C1DB8052
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 10:50:23 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 871E41DB804B
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 10:50:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/5] add isolate pages vmstat
In-Reply-To: <alpine.DEB.1.10.0907101447370.14152@gentwo.org>
References: <20090710094934.17CA.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0907101447370.14152@gentwo.org>
Message-Id: <20090713104954.624C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 13 Jul 2009 10:50:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

> On Fri, 10 Jul 2009, KOSAKI Motohiro wrote:
> 
> > Plus, current reclaim logic depend on the system have enough much pages on LRU.
> > Maybe we don't only need to limit #-of-reclaimer, but also need to limit #-of-migrator.
> > I think we can use similar logic.
> 
> I think your isolate pages counters can be used in both locations.
> 

I totally agree this :)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
