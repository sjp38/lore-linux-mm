Date: Sun, 23 Nov 2008 10:31:16 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [BUGFIX][PATCH mmotm] memcg: fix for hierarchical reclaim
Message-Id: <20081123103116.5dffa39a.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <4928113B.8090504@linux.vnet.ibm.com>
References: <20081122114446.42ddca46.d-nishimura@mtf.biglobe.ne.jp>
	<4928113B.8090504@linux.vnet.ibm.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, d-nishimura@mtf.biglobe.ne.jp, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Sat, 22 Nov 2008 19:33:39 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> Daisuke Nishimura wrote:
> > mem_cgroup_from_res_counter should handle both mem->res and mem->memsw.
> > This bug leads to NULL pointer dereference BUG at mem_cgroup_calc_reclaim.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> Thanks for catching this, could you please point me to the steps to reproduce
> the problem
> 
You can see this BUG when you are exceeding memory.memsw.limit_in_bytes
and trying to free pages.

When exceeding memory.memsw.limit_in_bytes, fail_res points to
mem_cgroup.memsw, not to mem_cgroup.res.
So, mem_cgroup_hierarchical_reclaim() would be called with
invalid mem_cgroup.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
