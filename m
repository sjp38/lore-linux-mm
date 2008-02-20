Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: Your message of "Wed, 20 Feb 2008 12:14:55 +0900"
	<20080220121455.d4e4daf6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080220121455.d4e4daf6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080220033724.A76CB1E3C58@siro.lan>
Date: Wed, 20 Feb 2008 12:37:24 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: hugh@veritas.com, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> On Tue, 19 Feb 2008 15:40:45 +0000 (GMT)
> Hugh Dickins <hugh@veritas.com> wrote:
> 
> > I haven't completed my solution in mem_cgroup_move_lists yet: but
> > the way it wants a lock in a structure which isn't stabilized until
> > it's got that lock, reminds me very much of my page_lock_anon_vma,
> > so I'm expecting to use a SLAB_DESTROY_BY_RCU cache there.
> > 
> Could I make a question about anon_vma's RCU ?
> 
> I think SLAB_DESTROY_BY_RCU guarantees that slab's page is not freed back
> to buddy allocator while some holds rcu_read_lock().
> 
> Why it's safe against reusing freed one by slab fast path (array_cache) ?

reuse for another anon_vma is ok.
page_check_address checks if it was really for this page.

YAMAMOTO Takashi

> 
> Thanks,
> -Kame
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
