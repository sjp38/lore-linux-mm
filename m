Date: Tue, 26 Feb 2008 10:39:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 12/15] memcg: css_put after remove_list
Message-Id: <20080226103924.e0481135.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0802252346280.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
	<Pine.LNX.4.64.0802252346280.27067@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 23:47:10 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> mem_cgroup_uncharge_page does css_put on the mem_cgroup before uncharging
> from it, and before removing page_cgroup from one of its lru lists: isn't
> there a danger that struct mem_cgroup memory could be freed and reused
> before completing that, so corrupting something?  Never seen it, and
> for all I know there may be other constraints which make it impossible;
> but let's be defensive and reverse the ordering there.
> 
> mem_cgroup_force_empty_list is safe because there's an extra css_get
> around all its works; but even so, change its ordering the same way
> round, to help get in the habit of doing it like this.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---

make sense

Acked-by: KAMEZAWA Hiroyiki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
