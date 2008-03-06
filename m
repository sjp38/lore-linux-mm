Message-Id: <47CFD957.3060402@mxp.nes.nec.co.jp>
Date: Thu, 06 Mar 2008 20:45:27 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH] cgroup swap subsystem
References: <47CE36A9.3060204@mxp.nes.nec.co.jp> <20080305155329.60e02f48.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080305155329.60e02f48.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: containers@lists.osdl.org, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi.

> At first look, remembering mm struct is not very good.
> Remembering swap controller itself is better.

The swap_cgroup when the page(and page_cgroup) is allocated and
the swap_cgroup when the page is going to be swapped out may be
different by swap_cgroup_move_task(), so I think swap_cgroup
to be charged should be determined at the point of swapout.

Instead of pointing mm_struct from page_cgroup, it would be
better to determine the mm_struct which the page to be swapped
out is belongs to by rmap, and charge swap_cgroup of the mm_struct.
In this implementation, I don't need to add new member to page_cgroup.

What do you think ?


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
