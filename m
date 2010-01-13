Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 393946B0071
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 03:27:25 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0D8RMlx007045
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 13 Jan 2010 17:27:22 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C31245DE4E
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 17:27:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E4CA45DE4C
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 17:27:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BD571DB803E
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 17:27:22 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F37CC1DB803A
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 17:27:21 +0900 (JST)
Date: Wed, 13 Jan 2010 17:24:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] [v2] memcg: add anon_scan_ratio to memory.stat file
Message-Id: <20100113172404.339b31dc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100113172143.B3E8.A69D9226@jp.fujitsu.com>
References: <20100113171734.B3E2.A69D9226@jp.fujitsu.com>
	<20100113172143.B3E8.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jan 2010 17:22:37 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Changelog
>   since v1: cancel to remove "recent_xxx" debug statistics as bilbir's
>   mention
> 
> ===========================================
> 
> anon_scan_ratio feature doesn't only useful for global VM pressure
> analysis, but it also useful for memcg memroy pressure analysis.
> 
> Then, this patch add anon_scan_ratio field to memory.stat file too.
> 
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
