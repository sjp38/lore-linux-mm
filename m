Date: Mon, 25 Feb 2008 17:28:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] radix-tree based page_cgroup. [6/7] radix-tree
 based page cgroup
Message-Id: <20080225172820.1d21df2f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080225.170229.54211092.taka@valinux.co.jp>
References: <20080225155211.f21fb44d.kamezawa.hiroyu@jp.fujitsu.com>
	<20080225.160540.80745258.taka@valinux.co.jp>
	<20080225162544.c1b680cc.kamezawa.hiroyu@jp.fujitsu.com>
	<20080225.170229.54211092.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, hugh@veritas.com, yamamoto@valinux.co.jp, ak@suse.de, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 17:02:29 +0900 (JST)
Hirokazu Takahashi <taka@valinux.co.jp> wrote:

> > - 28bytes * (2^7) = 3584 bytes. wastes 608 bytes per 512k of user memory. 
> > - 28bytes * (2^8) = 7168 bytes. wastes 1024 bytes per 1M of user memory.
> > 
> > loss is 0.1%. or any room user for page_cgroup's extra 4 bytes ?
> > 
> > Thanks,
> > -Kame
> 
> I feel kernel memory is an expensive resource especially on 32 bit linux
> machines. I think this is one of the reasones why a lot of people don't
> want to increase the size of page structure.
> 
Maybe the smallest loss case is 2^4. 

28bytes * 2^4 * 9 = 4032byes. (use private kmem_cache_alloc() here.)

I'll add this config and test it.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
