Date: Wed, 27 Feb 2008 19:47:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/15] memcg: mm_match_cgroup not vm_match_cgroup
Message-Id: <20080227194744.4de606e3.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0802252334190.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
	<Pine.LNX.4.64.0802252334190.27067@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 23:35:33 +0000 (GMT) Hugh Dickins <hugh@veritas.com> wrote:

> -#define vm_match_cgroup(mm, cgroup)	\
> +#define mm_match_cgroup(mm, cgroup)	\
>  	((cgroup) == rcu_dereference((mm)->mem_cgroup))

Could be written in C, methinks.

Unless we really want to be able to pass a `struct page_cgroup *' in place
of arg `mm' here.  If we don't want to be able to do that (prays fervently)
then let's sleep happily in the knowledge that the C type system prevents
us from doing it accidentally?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
