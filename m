Date: Wed, 4 Jun 2008 21:32:35 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][PATCH 2/2] memcg: hardwall hierarhcy for memcg
Message-Id: <20080604213235.defb1d01.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20080604140329.8db1b67e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
	<20080604140329.8db1b67e.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Hi.

> @@ -848,6 +937,8 @@ static int mem_cgroup_force_empty(struct
>  	if (mem_cgroup_subsys.disabled)
>  		return 0;
>  
> +	memcg_shrink_all(mem);
> +
>  	css_get(&mem->css);
>  	/*
>  	 * page reclaim code (kswapd etc..) will move pages between

Shouldn't it be called after verifying there remains no task
in this group?

If called via mem_cgroup_pre_destroy, it has been verified
that there remains no task already, but if called via
mem_force_empty_wrte, there may remain some tasks and
this means many and many pages are swaped out, doesn't it?


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
