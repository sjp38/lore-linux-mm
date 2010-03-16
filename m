Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id ABE736B0200
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 20:21:10 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2G0L8bl013819
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Mar 2010 09:21:08 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 32D2845DE7B
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:21:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0775545DE60
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:21:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C390D1DB8047
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:21:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BCB6A1DB8048
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:21:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: remove return value of putback_lru_pages
In-Reply-To: <1268658994.1889.8.camel@barrios-desktop>
References: <1268658994.1889.8.camel@barrios-desktop>
Message-Id: <20100316092041.4C34.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 16 Mar 2010 09:21:05 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Now putback_lru_page never can fail.
> So it doesn't matter count of "the number of pages put back".
> 
> In addition, users of this functions don't use return value.
> 
> Let's remove unnecessary code.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Thanks.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
