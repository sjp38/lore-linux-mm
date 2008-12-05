Date: Fri, 5 Dec 2008 21:22:08 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][PATCH -mmotm 0/4] patches for memory cgroup (20081205)
Message-Id: <20081205212208.31d904e0.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

Hi.

These are patches that I have now.

Patches:
  [1/4] memcg: don't trigger oom at page migration
  [2/4] memcg: remove mem_cgroup_try_charge
  [3/4] memcg: avoid deadlock caused by race between oom and cpuset_attach
  [4/4] memcg: change try_to_free_pages to hierarchical_reclaim

There is no special meaning in patch order except for 1 and 2.

Any comments would be welcome.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
