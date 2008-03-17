Message-ID: <47DDB9A5.1000405@cn.fujitsu.com>
Date: Mon, 17 Mar 2008 09:21:57 +0900
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] re-define page_cgroup.
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com> <20080314190313.e6e00026.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080314190313.e6e00026.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> (This is one of a series of patch for "lookup page_cgroup" patches..)
> 
>  * Exporting page_cgroup definition.
>  * Remove page_cgroup member from sturct page.
>  * As result, PAGE_CGROUP_LOCK_BIT and assign/access functions are removed.
> 
> Other chages will appear in following patches.
> There is a change in the structure itself, spin_lock is added.
> 
> Changelog:
>  - adjusted to rc5-mm1
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

Please don't break git-bisect. Make sure your patches can be applied one
by one.

mm/memcontrol.c: In function a??mem_cgroup_move_listsa??:
mm/memcontrol.c:309: error: implicit declaration of function a??try_lock_page_cgroupa??
mm/memcontrol.c:312: error: implicit declaration of function a??page_get_page_cgroupa??
mm/memcontrol.c:312: warning: assignment makes pointer from integer without a cast
mm/memcontrol.c:319: error: implicit declaration of function a??unlock_page_cgroupa??
mm/memcontrol.c: In function a??mem_cgroup_charge_commona??:
mm/memcontrol.c:490: error: implicit declaration of function a??lock_page_cgroupa??
mm/memcontrol.c:491: warning: assignment makes pointer from integer without a cast
mm/memcontrol.c:500: error: a??struct page_cgroupa?? has no member named a??ref_cnta??
mm/memcontrol.c:551: error: a??struct page_cgroupa?? has no member named a??ref_cnta??
mm/memcontrol.c:571: error: implicit declaration of function a??page_assign_page_cgroupa??
mm/memcontrol.c: In function a??mem_cgroup_uncharge_pagea??:
mm/memcontrol.c:621: warning: assignment makes pointer from integer without a cast
mm/memcontrol.c:628: error: a??struct page_cgroupa?? has no member named a??ref_cnta??
mm/memcontrol.c: In function a??mem_cgroup_prepare_migrationa??:
mm/memcontrol.c:661: warning: assignment makes pointer from integer without a cast
mm/memcontrol.c:663: error: a??struct page_cgroupa?? has no member named a??ref_cnta??
mm/memcontrol.c: In function a??mem_cgroup_page_migrationa??:
mm/memcontrol.c:685: warning: assignment makes pointer from integer without a cast

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
