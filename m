Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7806B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 20:43:11 -0500 (EST)
Date: Wed, 11 Nov 2009 10:35:33 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 0/3] some cleanups for memcg
Message-Id: <20091111103533.c634ff8d.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi.

These are cleanup patches split from my recharge-at-task-move patch set
posted in Nov/06.

[1/3] memcg: add mem_cgroup_cancel_charge()
[2/3] memcg: cleanup mem_cgroup_move_parent()
[3/3] memcg: remove memcg_tasklist

1 is corresponding to 3 in original patch set, and 2 to 4. There is no practical
change from then. I think they are ready for merge.

3 is a substitutional patch for 2 in original patch set. I want ack or some comments
about this patch.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
