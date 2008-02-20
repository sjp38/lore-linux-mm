Date: Wed, 20 Feb 2008 12:14:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
Message-Id: <20080220121455.d4e4daf6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0802191449490.6254@blonde.site>
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0802191449490.6254@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 19 Feb 2008 15:40:45 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> I haven't completed my solution in mem_cgroup_move_lists yet: but
> the way it wants a lock in a structure which isn't stabilized until
> it's got that lock, reminds me very much of my page_lock_anon_vma,
> so I'm expecting to use a SLAB_DESTROY_BY_RCU cache there.
> 
Could I make a question about anon_vma's RCU ?

I think SLAB_DESTROY_BY_RCU guarantees that slab's page is not freed back
to buddy allocator while some holds rcu_read_lock().

Why it's safe against reusing freed one by slab fast path (array_cache) ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
