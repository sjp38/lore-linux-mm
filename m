Date: Mon, 25 Feb 2008 17:02:29 +0900 (JST)
Message-Id: <20080225.170229.54211092.taka@valinux.co.jp>
Subject: Re: [RFC][PATCH] radix-tree based page_cgroup. [6/7] radix-tree
 based page cgroup
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20080225162544.c1b680cc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080225155211.f21fb44d.kamezawa.hiroyu@jp.fujitsu.com>
	<20080225.160540.80745258.taka@valinux.co.jp>
	<20080225162544.c1b680cc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: balbir@linux.vnet.ibm.com, hugh@veritas.com, yamamoto@valinux.co.jp, ak@suse.de, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> Hirokazu Takahashi <taka@valinux.co.jp> wrote:
> > The size of struct page_cgroup on 32bit will be 28byte,
> > so that sizeof(struct page_cgroup) * 2^8 = 28 * 2^8 = 7168 byte.
> > I'm not sure it is acceptable if we lose (8192 - 7168)/8192 = 0.125 = 12.5%
> > of memory for page_cgroup.
> > 
> > +struct page_cgroup {
> > +	struct page 		*page;       /* the page this accounts for*/
> > +	struct mem_cgroup 	*mem_cgroup; /* current cgroup subsys */
> > +	int    			flags;	     /* See below */
> > +	int    			refcnt;      /* reference count */
> > +	spinlock_t		lock;        /* lock for all above members */
> > +	struct list_head 	lru;         /* for per cgroup LRU */
> > +};
> > 
> 
> - 28bytes * (2^7) = 3584 bytes. wastes 608 bytes per 512k of user memory. 
> - 28bytes * (2^8) = 7168 bytes. wastes 1024 bytes per 1M of user memory.
> 
> loss is 0.1%. or any room user for page_cgroup's extra 4 bytes ?
> 
> Thanks,
> -Kame

I feel kernel memory is an expensive resource especially on 32 bit linux
machines. I think this is one of the reasones why a lot of people don't
want to increase the size of page structure.

Thank you,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
