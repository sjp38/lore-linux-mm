Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EF3156B002D
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 00:29:00 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1A1233EE0C1
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 14:28:58 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F3CAD45DE51
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 14:28:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DAD2545DD75
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 14:28:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CCF951DB803E
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 14:28:57 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9586E1DB802F
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 14:28:57 +0900 (JST)
Date: Wed, 9 Nov 2011 14:27:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mm] mm: memcg: remove unused node/section info from
 pc->flags fix
Message-Id: <20111109142741.d3e5480b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1111082108160.1250@sister.anvils>
References: <1320787408-22866-1-git-send-email-jweiner@redhat.com>
	<1320787408-22866-11-git-send-email-jweiner@redhat.com>
	<alpine.LSU.2.00.1111082108160.1250@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 8 Nov 2011 21:18:10 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Fix non-CONFIG_SPARSEMEM build, which failed with
> mm/page_cgroup.c: In function `alloc_node_page_cgroup':
> mm/page_cgroup.c:44: error: `start_pfn' undeclared (first use in this function)
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
