Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 63CE68D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 03:54:13 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9T7sA8S005706
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 29 Oct 2010 16:54:11 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C7BE245DE6E
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 16:54:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A502D45DE70
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 16:54:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8493B1DB8037
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 16:54:10 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F8131DB803F
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 16:54:07 +0900 (JST)
Date: Fri, 29 Oct 2010 16:48:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 11/11] memcg: check memcg dirty limits in page
 writeback
Message-Id: <20101029164835.06eef3cf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1288336154-23256-12-git-send-email-gthelen@google.com>
References: <1288336154-23256-1-git-send-email-gthelen@google.com>
	<1288336154-23256-12-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Oct 2010 00:09:14 -0700
Greg Thelen <gthelen@google.com> wrote:

> If the current process is in a non-root memcg, then
> balance_dirty_pages() will consider the memcg dirty limits
> as well as the system-wide limits.  This allows different
> cgroups to have distinct dirty limits which trigger direct
> and background writeback at different levels.
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Ideally, I think some comments in the code for "why we need double-check system's
dirty limit and memcg's dirty limit" will be appreciated.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
