Date: Wed, 20 Feb 2008 13:13:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
Message-Id: <20080220131356.51db25c9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080220033724.A76CB1E3C58@siro.lan>
References: <20080220121455.d4e4daf6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080220033724.A76CB1E3C58@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: hugh@veritas.com, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008 12:37:24 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> > Why it's safe against reusing freed one by slab fast path (array_cache) ?
> 
> reuse for another anon_vma is ok.
> page_check_address checks if it was really for this page.
> 
i.c. (and I checked migration code again and it does check.)

Then, page_cgroup should have some check code for using RCU or
use call_rcu() by itself.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
