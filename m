Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 666706B004A
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 21:34:18 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D0BA13EE0BC
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 10:34:14 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B3C4945DE55
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 10:34:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B1C845DD75
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 10:34:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BEBF1DB802F
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 10:34:14 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 480421DB803B
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 10:34:14 +0900 (JST)
Message-ID: <4DF5690C.4090000@jp.fujitsu.com>
Date: Mon, 13 Jun 2011 10:34:04 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 07/10] migration: clean up unmap_and_move
References: <cover.1307455422.git.minchan.kim@gmail.com> <cf5cd5055db22ae301e01294f191bd94b17e7775.1307455422.git.minchan.kim@gmail.com>
In-Reply-To: <cf5cd5055db22ae301e01294f191bd94b17e7775.1307455422.git.minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com

(2011/06/07 23:38), Minchan Kim wrote:
> The unmap_and_move is one of big messy functions.
> This patch try to clean up.
> 
> It can help readability and make unmap_and_move_ilru simple.
> unmap_and_move_ilru will be introduced by next patch.
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
