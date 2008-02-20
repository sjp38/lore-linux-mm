Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: Your message of "Wed, 20 Feb 2008 11:15:06 +0900"
	<20080220111506.27cb60f6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080220111506.27cb60f6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080220023226.6FB051E3C11@siro.lan>
Date: Wed, 20 Feb 2008 11:32:26 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, riel@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

> On Wed, 20 Feb 2008 11:05:12 +0900 (JST)
> yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:
> 
> 	error = 0;
> > > >  		lock_page_cgroup(page);
> > > 
> > > What is !page case in mem_cgroup_charge_xxx() ?
> > 
> > see a hack in shmem_getpage.
> > 
> Aha, ok. maybe we should add try_to_shrink_page_cgroup() for making room
> rather than adding special case.
> 
> Thanks,
> -Kame

yes.
or, even better, implement cgroup background reclaim.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
