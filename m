Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 93A976B0099
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 04:39:27 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n738vjRU003934
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 3 Aug 2009 17:57:45 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A3DC45DE4F
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 17:57:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E57245DE4E
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 17:57:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D5FE1DB8037
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 17:57:45 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B53171DB803E
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 17:57:41 +0900 (JST)
Date: Mon, 3 Aug 2009 17:55:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
Message-Id: <20090803175557.645b9ca3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090803174519.74673413.kamezawa.hiroyu@jp.fujitsu.com>
References: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com>
	<alpine.DEB.2.00.0907300219580.13674@chino.kir.corp.google.com>
	<20090730190216.5aae685a.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907301157100.9652@chino.kir.corp.google.com>
	<20090731093305.50bcc58d.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907310231370.25447@chino.kir.corp.google.com>
	<7f54310137837631f2526d4e335287fc.squirrel@webmail-b.css.fujitsu.com>
	<alpine.DEB.2.00.0907311212240.22732@chino.kir.corp.google.com>
	<77df8765230d9f83859fde3119a2d60a.squirrel@webmail-b.css.fujitsu.com>
	<alpine.DEB.2.00.0908011303050.22174@chino.kir.corp.google.com>
	<20090803104244.b58220ba.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0908030050160.30778@chino.kir.corp.google.com>
	<20090803170217.e98b2e46.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0908030107110.30778@chino.kir.corp.google.com>
	<20090803174519.74673413.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Aug 2009 17:45:19 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> "just inherit at fork, change at exec" is an usual manner, I think.
> If oom_adj_exec rather than oom_adj_child, I won't complain, more.
> 
But this/(and yours) requires users to rewrite their apps.
Then, breaks current API.
please fight with other guardians.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
