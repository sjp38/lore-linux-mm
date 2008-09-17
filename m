Date: Wed, 17 Sep 2008 14:50:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm] memcg: fix handling of shmem migration
Message-Id: <20080917145003.fb4d0b95.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080917144659.2e363edc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080917133149.b012a1c2.nishimura@mxp.nes.nec.co.jp>
	<20080917144659.2e363edc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Sep 2008 14:46:59 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 17 Sep 2008 13:31:49 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > PG_swapbacked flag of newpage should be set(if needed) before
> > mem_cgroup_prepare_migration, because mem_cgroup_charge_common
> > checks the flag and determines whether it sets PAGE_CGROUP_FLAG_FILE or not.
> > 
> > Before this patch, if migrating shmem/tmpfs pages, newpage would be
> > charged with PAGE_CGROUP_FLAG_FILE set, while oldpage has been charged
> > without the flag.
> > 
> Nice catch !
> Thank you. 
> 
> Hmm, should I add MEM_CGROUP_CHARGE_TYPE_SHMEM rather than
> setting flag to newpage ?
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
I acked but.. can't this change moved into memcontrol.c ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
