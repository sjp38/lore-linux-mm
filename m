Date: Tue, 27 May 2008 14:01:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC 0/4] memcg: background reclaim (v1)
Message-Id: <20080527140116.fb04b06b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>"yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

This is my current set of add-on patches for memory resource controller.
This works well but not well tested and not for usual people.
i.e..request for comments at early stage before being more complicated.

This set inculdes an implementation of background reclaim to memory resource
controller. I expect this helps I/O under memory resource controller very much.
(some good result with "dd")

pathces are based on 2.6.26-rc2-mm1 + remove_refcnt patch set (in mm queue)
So, I don't ask you "pleaset test" ;)
plz tell me if you don't like the concept or you have better idea.

[1/4] freeing all at force_empty.
[2/4] high-low watermark to resource counter.
[3/4] background reclaim for memcg.
[4/4] background reclaim for memcg, NUMA extension.

Consideration:
One problem of background reclaim is that it uses CPU. I think it's necessary
to make them more moderate. But what can I do against kthread rather than
nice() ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
