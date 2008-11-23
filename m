Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id mAN7F99n004354
	for <linux-mm@kvack.org>; Sun, 23 Nov 2008 12:45:09 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAN7Ea9P3981458
	for <linux-mm@kvack.org>; Sun, 23 Nov 2008 12:44:36 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id mAN7F8T4024796
	for <linux-mm@kvack.org>; Sun, 23 Nov 2008 12:45:09 +0530
Message-ID: <492902F8.1060806@linux.vnet.ibm.com>
Date: Sun, 23 Nov 2008 12:45:04 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [BUGFIX][PATCH mmotm] memcg: fix for hierarchical reclaim
References: <20081122114446.42ddca46.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20081122114446.42ddca46.d-nishimura@mtf.biglobe.ne.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nishimura@mxp.nes.nec.co.jp
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, d-nishimura@mtf.biglobe.ne.jp
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> mem_cgroup_from_res_counter should handle both mem->res and mem->memsw.
> This bug leads to NULL pointer dereference BUG at mem_cgroup_calc_reclaim.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
> This is fix for memory-cgroup-hierarchical-reclaim-v4.patch.

Tested-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
