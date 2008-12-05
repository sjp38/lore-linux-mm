Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB5DUfJa007724
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Dec 2008 22:30:41 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D0CB45DE51
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 22:30:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7305A45DD79
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 22:30:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 553E11DB803F
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 22:30:41 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 10BB61DB803C
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 22:30:41 +0900 (JST)
Message-ID: <58995.10.75.179.61.1228483840.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20081205212529.8d895526.nishimura@mxp.nes.nec.co.jp>
References: <20081205212208.31d904e0.nishimura@mxp.nes.nec.co.jp>
    <20081205212529.8d895526.nishimura@mxp.nes.nec.co.jp>
Date: Fri, 5 Dec 2008 22:30:40 +0900 (JST)
Subject: Re: [RFC][PATCH -mmotm 4/4] memcg: change try_to_free_pages
     tohierarchical_reclaim
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura said:
> mem_cgroup_hierarchicl_reclaim() works properly even when !use_hierarchy
> now,
> so, instead of try_to_free_mem_cgroup_pages(), it should be used in many
> cases.
>
> The only exception is force_empty. The group has no children in this case.
>
Hmm...I postponed this until removing cgroup_lock from reclaim..
But ok, this is a way to go,
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
