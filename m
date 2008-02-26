Date: Tue, 26 Feb 2008 10:36:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 10/15] memcg: memcontrol uninlined and static
Message-Id: <20080226103638.81f38ae8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0802252343230.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
	<Pine.LNX.4.64.0802252343230.27067@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Adrian Bunk <bunk@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 23:44:44 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> More cleanup to memcontrol.c, this time changing some of the code generated.
> Let the compiler decide what to inline (except for page_cgroup_locked which
> is only used when CONFIG_DEBUG_VM): the __always_inline on lock_page_cgroup
> etc. was quite a waste since bit_spin_lock etc. are inlines in a header file;
> made mem_cgroup_force_empty and mem_cgroup_write_strategy static.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
