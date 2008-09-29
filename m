Date: Mon, 29 Sep 2008 19:19:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/4] memcg: ready-to-go series (was memcg update v6)
Message-Id: <20080929191927.caabec89.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Cut out 4 patches from memcg update v5 series.
(Then, this is a part of v6)

I think we got some agreement on these 4.

please ack if ok.

[1/4] ...  account swap under lock
[2/4] ...  make page->mapping to be NULL before uncharge cache.
[3/4] ...  avoid accounting not-on-LRU pages.
[4/4] ...  optimize cpu stat

I still have 6 patches but it's under test and needs review and discussion.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
