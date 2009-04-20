Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 429F05F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 01:19:35 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3K5Jolq011283
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 20 Apr 2009 14:19:50 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 61CC445DE52
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 14:19:50 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4363845DE4E
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 14:19:50 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 26E2D1DB8040
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 14:19:50 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DAB351DB8038
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 14:19:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my case?
In-Reply-To: <49EC029D.1060807@gmail.com>
References: <20090420135323.08015e32.minchan.kim@barrios-desktop> <49EC029D.1060807@gmail.com>
Message-Id: <20090420141710.2509.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 20 Apr 2009 14:19:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The v4l2 method IO_METHOD_MMAP does use the vmaloc() method you told above ,
> our driver also support this method,we user vmalloc /remap_vmalloc_range().
> 
> But the v4l2 method IO_METHOD_USERPTR must use the method I told above.

I guess you mean IO_METHOD_USERPTR can't use remap_vmalloc_range, right?
we need explanation of v4l2 requirement.

Can you explain why v4l2 use two different way? Why application developer
need two way?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
