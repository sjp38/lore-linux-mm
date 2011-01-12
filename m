Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A606B6B0092
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 19:53:43 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B1EB33EE0B3
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 09:53:41 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B58245DE68
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 09:53:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8441645DE55
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 09:53:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 77E6F1DB803C
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 09:53:41 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4307D1DB8038
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 09:53:41 +0900 (JST)
Date: Wed, 12 Jan 2011 09:47:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg: remove unnecessary BUG_ON
Message-Id: <20110112094750.46623489.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <41390917af25769cd59eb001370b80ef6520a8bb.1294735182.git.minchan.kim@gmail.com>
References: <41390917af25769cd59eb001370b80ef6520a8bb.1294735182.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jan 2011 17:51:11 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Now memcg in unmap_and_move checks BUG_ON of charge.
> mem_cgroup_prepare_migration returns either 0 or -ENOMEM.
> If it returns -ENOMEM, it jumps out unlock without the check.
> If it returns 0, it can pass BUG_ON. So it's meaningless.
> Let's remove it.
> 
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
