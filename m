Date: Thu, 22 May 2008 16:44:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] swapcgroup(v2)
Message-Id: <20080522164421.84849565.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48350F15.9070007@mxp.nes.nec.co.jp>
References: <48350F15.9070007@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

On Thu, 22 May 2008 15:13:41 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Hi.
> 
> I updated my swapcgroup patch.
> 
seems good in general.


> Major changes from previous version(*1):
> - Rebased on 2.6.26-rc2-mm1 + KAMEZAWA-san's performance
>   improvement patchset v4.
> - Implemented as a add-on to memory cgroup.
>   So, there is no need to add a new member to page_cgroup now.
> - (NEW)Modified vm_swap_full() to calculate the rate of
>   swap usage per cgroup.
> 
> Patchs:
> - [1/4] add cgroup files
> - [2/4] add member to swap_info_struct for cgroup
> - [3/4] implement charge/uncharge
> - [4/4] modify vm_swap_full for cgroup
> 
> ToDo:
> - handle force_empty.

Without this, we can do rmdir() against cgroup with swap. right ?

> - make it possible for users to select if they use
>   this feature or not, and avoid overhead for users
>   not using this feature.
> - move charges along with task move between cgroups.
> 
I think memory-controller's anon pages should also do this....
But how do you think about shared entries ?



Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
