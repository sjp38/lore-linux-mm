Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 614B66B0085
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 21:05:45 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J15hgw004904
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 19 Oct 2010 10:05:43 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A113745DE57
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:05:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7486445DE63
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:05:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A7F7E08001
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:05:42 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E69CE08002
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:05:41 +0900 (JST)
Date: Tue, 19 Oct 2010 10:00:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 11/11] memcg: check memcg dirty limits in page
 writeback
Message-Id: <20101019100015.7a0d4695.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1287448784-25684-12-git-send-email-gthelen@google.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-12-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Oct 2010 17:39:44 -0700
Greg Thelen <gthelen@google.com> wrote:

> If the current process is in a non-root memcg, then
> global_dirty_limits() will consider the memcg dirty limit.
> This allows different cgroups to have distinct dirty limits
> which trigger direct and background writeback at different
> levels.
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
