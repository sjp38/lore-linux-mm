Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1BBAD8D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 00:56:43 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 18BB33EE0AE
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 14:56:38 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F391245DE4E
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 14:56:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DD67D45DE4D
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 14:56:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CFF9C1DB8037
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 14:56:37 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A70E1DB803B
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 14:56:37 +0900 (JST)
Date: Thu, 24 Feb 2011 14:50:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: more mem_cgroup_uncharge batching
Message-Id: <20110224145016.794247a0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1102232139560.2239@sister.anvils>
References: <alpine.LSU.2.00.1102232139560.2239@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@in.ibm.com>, Daisuke Nishimura <nishmura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 23 Feb 2011 21:44:33 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> It seems odd that truncate_inode_pages_range(), called not only when
> truncating but also when evicting inodes, has mem_cgroup_uncharge_start
> and _end() batching in its second loop to clear up a few leftovers, but
> not in its first loop that does almost all the work: add them there too.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Thank you.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
