Date: Thu, 22 May 2008 16:39:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] swapcgroup: modify vm_swap_full for cgroup
Message-Id: <20080522163938.9045f624.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48351120.6000800@mxp.nes.nec.co.jp>
References: <48350F15.9070007@mxp.nes.nec.co.jp>
	<48351120.6000800@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 22 May 2008 15:22:24 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> +	mem = p->memcg[swp_offset(entry)];
> +	usage = swap_cgroup_read_usage(mem) / PAGE_SIZE;
> +	limit = swap_cgroup_read_limit(mem) / PAGE_SIZE;
> +	limit = (limit < total_swap_pages) ? limit : total_swap_pages;

mem can be NULL here.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
