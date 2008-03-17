Message-Id: <47DE2894.6010306@mxp.nes.nec.co.jp>
Date: Mon, 17 Mar 2008 17:15:16 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] another swap controller for cgroup
References: <20080317020407.8512E1E7995@siro.lan>
In-Reply-To: <20080317020407.8512E1E7995@siro.lan>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: yamamoto@valinux.co.jp
Cc: Hugh Dickins <hugh@veritas.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, minoura@valinux.co.jp, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi, Yamamoto-san.

I'm reviewing and testing your patch now.

I think your implementation is better because:
- the group to be charged is determined correctly
  at the point of swapout, without fixing the behavior
  of move_task of memcg.
  (I think the behavior of move_task of memcg should be
  fixed anyway.)
- the group to be uncharged is remembered in page struct
  of pmd, so there is no need to add array of pointers
  to swap_info_struct.

> - anonymous objects (shmem) are not accounted.
IMHO, shmem should be accounted.
I agree it's difficult in your implementation,
but are you going to support it?


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
