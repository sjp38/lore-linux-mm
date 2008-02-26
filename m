Date: Mon, 25 Feb 2008 16:39:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 01/15] memcg: mm_match_cgroup not vm_match_cgroup
In-Reply-To: <Pine.LNX.4.64.0802252334190.27067@blonde.site>
Message-ID: <alpine.DEB.1.00.0802251638470.7785@chino.kir.corp.google.com>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site> <Pine.LNX.4.64.0802252334190.27067@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008, Hugh Dickins wrote:

> vm_match_cgroup is a perverse name for a macro to match mm with cgroup:
> rename it mm_match_cgroup, matching mm_init_cgroup and mm_free_cgroup.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

+torvalds, who suggested the vm_match_cgroup name.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
