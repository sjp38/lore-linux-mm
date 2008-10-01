Date: Wed, 1 Oct 2008 16:52:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/6] memcg update v6 (for review and discuss)
Message-Id: <20081001165233.404c8b9c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This series is update from v5.

easy 4 patches are already posted as ready-to-go-series.

This is need-more-discuss set.

Includes following 6 patches. (reduced from v5).
The whole series are reordered.

[1/6] make page_cgroup->flags to be atomic.
[2/6] allocate all page_cgroup at boot.
[3/6] rewrite charge path by charge/commit/cancel
[4/6] new force_empty and move_account
[5/6] lazy lru free
[6/6] lazy lru add.

Patch [3/6] and [4/6] are totally rewritten.
Races in Patch [6/6] is fixed....I think.

Patch [1-4] seems to be big but there is no complicated ops.
Patch [5-6] is more racy. Check-by-regression-test is necessary.
(Of course, I does some.)

If ready-to-go-series goes, next is patch 1 and 2.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
