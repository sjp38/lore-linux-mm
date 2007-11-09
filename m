Date: Fri, 9 Nov 2007 18:21:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/6 mm] memcgroup: revert swap_state mods
Message-Id: <20071109182156.7174e92b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0711090713300.21663@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0711090700530.21638@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0711090713300.21663@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, containers@lists.osdl.org
List-ID: <linux-mm.kvack.org>

On Fri, 9 Nov 2007 07:14:22 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> If we're charging rss and we're charging cache, it seems obvious that
> we should be charging swapcache - as has been done.  But in practice
> that doesn't work out so well: both swapin readahead and swapoff leave
> the majority of pages charged to the wrong cgroup (the cgroup that
> happened to read them in, rather than the cgroup to which they belong).
> 

Thank you. I welcome this patch :)

Could I confirm a change in the logic  ?

 * Before this patch, wrong swapcache charge is added to one who
   called try_to_free_page().

 * After this patch, anonymous page's charge will drop to 0 when
   page_remove_rmap() is called.


Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
