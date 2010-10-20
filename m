Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C558E5F0048
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 00:24:31 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9K4OSxV000930
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 20 Oct 2010 13:24:28 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D96B45DE54
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 13:24:28 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EDACA45DE4F
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 13:24:27 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CF5721DB805A
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 13:24:27 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 85D911DB8043
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 13:24:27 +0900 (JST)
Date: Wed, 20 Oct 2010 13:18:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 11/11] memcg: check memcg dirty limits in page
 writeback
Message-Id: <20101020131857.cd0ecd38.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101019100015.7a0d4695.kamezawa.hiroyu@jp.fujitsu.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-12-git-send-email-gthelen@google.com>
	<20101019100015.7a0d4695.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 19 Oct 2010 10:00:15 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 18 Oct 2010 17:39:44 -0700
> Greg Thelen <gthelen@google.com> wrote:
> 
> > If the current process is in a non-root memcg, then
> > global_dirty_limits() will consider the memcg dirty limit.
> > This allows different cgroups to have distinct dirty limits
> > which trigger direct and background writeback at different
> > levels.
> > 
> > Signed-off-by: Andrea Righi <arighi@develer.com>
> > Signed-off-by: Greg Thelen <gthelen@google.com>
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
Why FREEPAGES in memcg is not counted as dirtyable ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
