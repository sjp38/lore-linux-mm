Message-ID: <47CFE2A5.4000407@openvz.org>
Date: Thu, 06 Mar 2008 15:25:09 +0300
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH] cgroup swap subsystem
References: <47CE36A9.3060204@mxp.nes.nec.co.jp> <20080305155329.60e02f48.kamezawa.hiroyu@jp.fujitsu.com> <47CFD957.3060402@mxp.nes.nec.co.jp>
In-Reply-To: <47CFD957.3060402@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, containers@lists.osdl.org, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> Hi.
> 
>> At first look, remembering mm struct is not very good.
>> Remembering swap controller itself is better.
> 
> The swap_cgroup when the page(and page_cgroup) is allocated and
> the swap_cgroup when the page is going to be swapped out may be
> different by swap_cgroup_move_task(), so I think swap_cgroup
> to be charged should be determined at the point of swapout.

No. Since we now do not account for the situation, when pages are
shared between cgroups, we may think, that the cgroup, which the 
page was allocated by and the cgroup, which this pages goes to swap 
in are the same.

> Instead of pointing mm_struct from page_cgroup, it would be
> better to determine the mm_struct which the page to be swapped
> out is belongs to by rmap, and charge swap_cgroup of the mm_struct.
> In this implementation, I don't need to add new member to page_cgroup.
> 
> What do you think ?
> 
> 
> Thanks,
> Daisuke Nishimura.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
