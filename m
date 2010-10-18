Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0942B200015
	for <linux-mm@kvack.org>; Sun, 17 Oct 2010 21:00:09 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9I107Fj030170
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 18 Oct 2010 10:00:07 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D578545DE81
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 10:00:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A7FA845DE6F
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 10:00:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 59B24EF800C
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 10:00:05 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CF9071DB803F
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 10:00:04 +0900 (JST)
Date: Mon, 18 Oct 2010 09:54:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2 10/11] writeback: make determine_dirtyable_memory()
 static.
Message-Id: <20101018095436.bb08bf2e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1287177279-30876-11-git-send-email-gthelen@google.com>
References: <1287177279-30876-1-git-send-email-gthelen@google.com>
	<1287177279-30876-11-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 15 Oct 2010 14:14:38 -0700
Greg Thelen <gthelen@google.com> wrote:

> The determine_dirtyable_memory() function is not used outside of
> page writeback.  Make the routine static.  No functional change.
> Just a cleanup in preparation for a change that adds memcg dirty
> limits consideration into global_dirty_limits().
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
