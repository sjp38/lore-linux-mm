Message-Id: <47E79A26.3070401@mxp.nes.nec.co.jp>
Date: Mon, 24 Mar 2008 21:10:14 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] another swap controller for cgroup
References: <20080317020407.8512E1E7995@siro.lan> <47DE2894.6010306@mxp.nes.nec.co.jp>
In-Reply-To: <47DE2894.6010306@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: yamamoto@valinux.co.jp
Cc: Hugh Dickins <hugh@veritas.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, minoura@valinux.co.jp, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> Hi, Yamamoto-san.
> 
> I'm reviewing and testing your patch now.
> 

In building kernel infinitely(in a cgroup of
memory.limit=64M and swap.limit=128M, with swappiness=100),
almost all of the swap (1GB) is consumed as swap cache
after a day or so.
As a result, processes are occasionally OOM-killed even when
the swap.usage of the group doesn't exceed the limit.

I don't know why the swap cache uses up swap space.
I will test whether a similar issue happens without your patch.
Do you have any thoughts?


BTW, I think that it would be better, in the sence of
isolating memory resource, if there is a framework
to limit the usage of swap cache.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
