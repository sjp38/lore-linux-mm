Date: Wed, 1 Oct 2008 14:32:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 9/12] memcg allocate all page_cgroup at boot
Message-Id: <20081001143242.1b44de24.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081001140748.637b9831.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20080925153206.281243dc.kamezawa.hiroyu@jp.fujitsu.com>
	<48E2F6A9.9010607@linux.vnet.ibm.com>
	<20081001140748.637b9831.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Wed, 1 Oct 2008 14:07:48 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Can we make this patch indepedent of the flags changes and push it in ASAP.
> > 
> Need much work....Hmm..rewrite all again ? 
> 

BTW, do you have good idea to modify flag bit without affecting LOCK bit on
page_cgroup->flags ?

At least, we'll have to set ACTIVE/INACTIVE/UNEVICTABLE flags dynamically.
take lock_page_cgroup() always ?
__mem_cgroup_move_lists() will have some amount of changes. And we should
check dead lock again.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
