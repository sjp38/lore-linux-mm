Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2E7166B004F
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 04:52:53 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n669SGb4004449
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 6 Jul 2009 18:28:16 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 58A6C45DE70
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 18:28:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AF3A545DE6E
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 18:28:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B747B1DB8049
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 18:28:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 617BBE08019
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 18:28:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/5] add isolate pages vmstat
In-Reply-To: <28c262360907050751t1fccbf4t4ace572b4e003a13@mail.gmail.com>
References: <20090705211127.0917.A69D9226@jp.fujitsu.com> <28c262360907050751t1fccbf4t4ace572b4e003a13@mail.gmail.com>
Message-Id: <20090706182750.0C54.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  6 Jul 2009 18:28:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > ? ? ? ?printk("Active_anon:%lu active_file:%lu inactive_anon:%lu\n"
> > - ? ? ? ? ? ? ? " inactive_file:%lu"
> > - ? ? ? ? ? ? ? " unevictable:%lu"
> > + ? ? ? ? ? ? ? " inactive_file:%lu unevictable:%lu isolated:%lu\n"
> 
> It's good.
> I have a one suggestion.
> 
> I know this patch came from David's OOM problem a few days ago.
> 
> I think total pages isolated of all lru doesn't help us much.
> It just represents why [in]active[anon/file] is zero.
> 
> How about adding isolate page number per each lru ?
> 
> IsolatedPages(file)
> IsolatedPages(anon)
> 
> It can help knowing exact number of each lru.

Good suggestion!
Will fix.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
