Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 29ECF8D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 01:53:49 -0500 (EST)
Date: Thu, 24 Feb 2011 15:47:45 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: more mem_cgroup_uncharge batching
Message-Id: <20110224154745.b7d7a0ac.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <alpine.LSU.2.00.1102232139560.2239@sister.anvils>
References: <alpine.LSU.2.00.1102232139560.2239@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@in.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 23 Feb 2011 21:44:33 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> It seems odd that truncate_inode_pages_range(), called not only when
> truncating but also when evicting inodes, has mem_cgroup_uncharge_start
> and _end() batching in its second loop to clear up a few leftovers, but
> not in its first loop that does almost all the work: add them there too.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
Thank you catching this. This patch has already got enough ack's, but anyway:

	Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

P.S.
My address is "nishimura@mxp.nes.nec.co.jp", not "nishmura@mxp.nes.nec.co.jp" :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
