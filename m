Date: Tue, 17 Jun 2008 12:31:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/2] memcg: Reduce usage at change limit
Message-Id: <20080617123144.ce5a74fa.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi, this is a patch for reducing usage at the change of limit for memcg.
A cut out from hierarchy patch set.I added Andrew Morton to CC.

I think this version is enough neat and small. 
This patch implements only necessary things.

Change log (hierarchy set's) v4 -> (this version) v5.
 - just for changing limit.
 - avoid to add rich limit handlers to res_counter because..
   1. memcg is maybe an only user which shrink_usage can be implemented.
   2. Many objections ;)

This patch adds feedback control at set_limit as following

   -> user's request to set limit to 'val'
      1. try to set limit to 'val'
      2. at success goto 6.
      3. try to shrink usage...
      4. if we cannot make progress any more, return -EBUSY.
      5. goto 1.
      6. successs.

Tested on x86-64.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
