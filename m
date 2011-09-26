Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF039000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 05:21:00 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 42BB53EE0C0
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:20:56 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2391845DE96
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:20:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 070F245DE94
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:20:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EC71C1DB803E
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:20:55 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B96B21DB8037
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:20:55 +0900 (JST)
Date: Mon, 26 Sep 2011 18:20:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/1] vmscan.c: Invalid strict_strtoul check in
 write_scan_unevictable_node
Message-Id: <20110926182011.dc621e9c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1316948380-1879-1-git-send-email-consul.kautuk@gmail.com>
References: <1316948380-1879-1-git-send-email-consul.kautuk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 25 Sep 2011 16:29:40 +0530
Kautuk Consul <consul.kautuk@gmail.com> wrote:

> write_scan_unavictable_node checks the value req returned by
> strict_strtoul and returns 1 if req is 0.
> 
> However, when strict_strtoul returns 0, it means successful conversion
> of buf to unsigned long.
> 
> Due to this, the function was not proceeding to scan the zones for
> unevictable pages even though we write a valid value to the 
> scan_unevictable_pages sys file.
> 
> Changing this if check slightly to check for invalid value 
> in buf as well as 0 value stored in res after successful conversion
> via strict_strtoul.
> In both cases, we do not perform the scanning of this node's zones.
> 
> Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
