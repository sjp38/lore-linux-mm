Message-ID: <48FD74AB.9010307@cn.fujitsu.com>
Date: Tue, 21 Oct 2008 14:20:27 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [memcg BUG] unable to handle kernel NULL pointer derefence at 00000000
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>	<20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>	<6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>	<20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>	<48FD6901.6050301@linux.vnet.ibm.com> <20081021143955.eeb86d49.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081021143955.eeb86d49.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> BTW, "allocate all page_cgroup at boot" patch goes to Linus' git. Wow.
> 

But seems this patch causes kernel panic at system boot ... (or maybe one of other
memcg patches?)

I wrote down the panic manually:

BUG: unable to handle kernel NULL pointer dereference at 00000000
IP: page_cgroup_zoneinfo + 0xa

Call Trace:
? mem_cgroup_charge_common + 0x17d
? mem_cgroup_charge
? add_to_page_cache_locked
? add_to_page_cache_lru
? find_or_create_page
? __getblk
? ext3_get_inode_loc
? ext3_iget
? ext3_lookup

Tell me if you need extra information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
