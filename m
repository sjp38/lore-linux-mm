Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB5DMllO023618
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Dec 2008 22:22:47 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 40D5D45DD75
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 22:22:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E8A745DD72
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 22:22:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DE14A1DB8041
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 22:22:46 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A7771DB803F
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 22:22:46 +0900 (JST)
Message-ID: <56250.10.75.179.61.1228483365.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20081205212304.f7018ea1.nishimura@mxp.nes.nec.co.jp>
References: <20081205212208.31d904e0.nishimura@mxp.nes.nec.co.jp>
    <20081205212304.f7018ea1.nishimura@mxp.nes.nec.co.jp>
Date: Fri, 5 Dec 2008 22:22:45 +0900 (JST)
Subject: Re: [RFC][PATCH -mmotm 1/4] memcg: don't trigger oom at page
     migration
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
> I think triggering OOM at mem_cgroup_prepare_migration would be just a bit
> overkill.
> Returning -ENOMEM would be enough for mem_cgroup_prepare_migration.
> The caller would handle the case anyway.
>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4dbce1d..50ee1be 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1330,7 +1330,7 @@ int mem_cgroup_prepare_migration(struct page *page,
> struct mem_cgroup **ptr)
>  	unlock_page_cgroup(pc);
>
>  	if (mem) {
> -		ret = mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem);
> +		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
>  		css_put(&mem->css);
>  	}
>  	*ptr = mem;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
