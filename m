Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 0BCCB6B0068
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 02:57:57 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 78EAB3EE0B5
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:57:56 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 62EA545DE4E
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:57:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A64845DE4F
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:57:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F3DA1DB803E
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:57:56 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D50A91DB8037
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:57:55 +0900 (JST)
Message-ID: <4FDC2DEA.6010300@jp.fujitsu.com>
Date: Sat, 16 Jun 2012 15:55:38 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: clear pages_scanned only if draining a pcp adds pages
 to the buddy allocator again
References: <1339690570-7471-1-git-send-email-kosaki.motohiro@gmail.com>
In-Reply-To: <1339690570-7471-1-git-send-email-kosaki.motohiro@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>

(2012/06/15 1:16), kosaki.motohiro@gmail.com wrote:
> From: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> 
> commit 2ff754fa8f (mm: clear pages_scanned only if draining a pcp adds pages
> to the buddy allocator again) fixed one free_pcppages_bulk() misuse. But two
> another miuse still exist.
> 
> This patch fixes it.
> 
> Cc: David Rientjes<rientjes@google.com>
> Cc: Mel Gorman<mel@csn.ul.ie>
> Cc: Johannes Weiner<hannes@cmpxchg.org>
> Cc: Minchan Kim<minchan.kim@gmail.com>
> Cc: Wu Fengguang<fengguang.wu@intel.com>
> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Rik van Riel<riel@redhat.com>
> Cc: Andrew Morton<akpm@linux-foundation.org>
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
