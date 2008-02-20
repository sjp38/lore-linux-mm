Date: Wed, 20 Feb 2008 11:15:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
Message-Id: <20080220111506.27cb60f6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080220020512.E0BF91E3C5B@siro.lan>
References: <20080220105538.6e7bbaba.kamezawa.hiroyu@jp.fujitsu.com>
	<20080220020512.E0BF91E3C5B@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, riel@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008 11:05:12 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

	error = 0;
> > >  		lock_page_cgroup(page);
> > 
> > What is !page case in mem_cgroup_charge_xxx() ?
> 
> see a hack in shmem_getpage.
> 
Aha, ok. maybe we should add try_to_shrink_page_cgroup() for making room
rather than adding special case.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
