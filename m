Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 144076B01FC
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 20:22:25 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3E0MMWu006292
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Apr 2010 09:22:22 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 446E145DE6E
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 09:22:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 22FDC45DE60
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 09:22:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0095B1DB8041
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 09:22:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 936731DB8042
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 09:22:21 +0900 (JST)
Date: Wed, 14 Apr 2010 09:18:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/6] change alloc function in alloc_slab_page
Message-Id: <20100414091825.0bacfe48.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <8b348d9cc1ea4960488b193b7e8378876918c0d4.1271171877.git.minchan.kim@gmail.com>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
	<8b348d9cc1ea4960488b193b7e8378876918c0d4.1271171877.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Apr 2010 00:25:00 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> alloc_slab_page never calls alloc_pages_node with -1.
> It means node's validity check is unnecessary.
> So we can use alloc_pages_exact_node instead of alloc_pages_node.
> It could avoid comparison and branch as 6484eb3e2a81807722 tried.
> 
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
