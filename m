Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 423326B0187
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 21:23:16 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id F3BF53EE0BC
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 10:23:12 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EC1DB45DE55
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 10:23:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AABFE3E60C3
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 10:23:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C98E1DB8054
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 10:23:07 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F7451DB8051
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 10:23:07 +0900 (JST)
Date: Thu, 18 Aug 2011 10:15:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v9 10/13] writeback: pass wb_writeback_work into
 move_expired_inodes()
Message-Id: <20110818101538.9a679fcf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1313597705-6093-11-git-send-email-gthelen@google.com>
References: <1313597705-6093-1-git-send-email-gthelen@google.com>
	<1313597705-6093-11-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>

On Wed, 17 Aug 2011 09:15:02 -0700
Greg Thelen <gthelen@google.com> wrote:

> A later change to move_expired_inodes() requires passing fields from
> writeback work descriptor into memcontrol code when determining if an
> inode should be written back considered.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
