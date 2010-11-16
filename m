Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 28D028D006C
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 22:55:39 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAG3tacK007252
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Nov 2010 12:55:37 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B490B45DE55
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:55:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 89B4945DE51
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:55:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EA231DB803C
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:55:36 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CBA91DB8038
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:55:33 +0900 (JST)
Date: Tue, 16 Nov 2010 12:50:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/6] memcg: add mem_cgroup parameter to
 mem_cgroup_page_stat()
Message-Id: <20101116125004.428b6eac.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1289294671-6865-2-git-send-email-gthelen@google.com>
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
	<1289294671-6865-2-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue,  9 Nov 2010 01:24:26 -0800
Greg Thelen <gthelen@google.com> wrote:

> This new parameter can be used to query dirty memory usage
> from a given memcg rather than the current task's memcg.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
