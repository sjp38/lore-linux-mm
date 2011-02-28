Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EE7878D0039
	for <linux-mm@kvack.org>; Sun, 27 Feb 2011 21:35:12 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 690D73EE0CD
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:35:09 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CC8A45DE54
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:35:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 33F5045DE51
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:35:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CE00D1DB803E
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:35:08 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 87E78E78003
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:35:08 +0900 (JST)
Date: Mon, 28 Feb 2011 11:28:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 3/9] writeback: convert variables to unsigned
Message-Id: <20110228112846.454cea86.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1298669760-26344-4-git-send-email-gthelen@google.com>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
	<1298669760-26344-4-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>

On Fri, 25 Feb 2011 13:35:54 -0800
Greg Thelen <gthelen@google.com> wrote:

> Convert two balance_dirty_pages() page counter variables (nr_reclaimable
> and nr_writeback) from 'long' to 'unsigned long'.
> 
> These two variables are used to store results from global_page_state().
> global_page_state() returns unsigned long and carefully sums per-cpu
> counters explicitly avoiding returning a negative value.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Reviewd-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
