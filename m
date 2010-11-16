Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 433738D006C
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 22:52:42 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAG3qdXA005997
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Nov 2010 12:52:40 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AFE245DE51
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:52:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 489BD45DE4E
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:52:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D11E3E08001
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:52:38 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2ACEFE08002
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:52:35 +0900 (JST)
Date: Tue, 16 Nov 2010 12:47:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: avoid "free" overflow in
 memcg_hierarchical_free_pages()
Message-Id: <20101116124704.c68288b5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1289292853-7022-1-git-send-email-gthelen@google.com>
References: <1289292853-7022-1-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue,  9 Nov 2010 00:54:13 -0800
Greg Thelen <gthelen@google.com> wrote:

> memcg limit and usage values are stored in res_counter, as 64-bit
> numbers, even on 32-bit machines.  The "free" variable in
> memcg_hierarchical_free_pages() stores the difference between two
> 64-bit numbers (limit - current_usage), and thus should be stored
> in a 64-bit local rather than a machine defined unsigned long.
> 
> Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
