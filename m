Date: Thu, 06 Mar 2008 06:51:53 +0900 (JST)
Message-Id: <20080306.065153.22592867.taka@valinux.co.jp>
Subject: Re: [RFC/PATCH] cgroup swap subsystem
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20080305155329.60e02f48.kamezawa.hiroyu@jp.fujitsu.com>
References: <47CE36A9.3060204@mxp.nes.nec.co.jp>
	<20080305155329.60e02f48.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nishimura@mxp.nes.nec.co.jp
Cc: kamezawa.hiroyu@jp.fujitsu.com, containers@lists.osdl.org, linux-mm@kvack.org, xemul@openvz.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Hi,

> >  #ifdef CONFIG_CGROUP_MEM_CONT
> > +/*
> > + * A page_cgroup page is associated with every page descriptor. The
> > + * page_cgroup helps us identify information about the cgroup
> > + */
> > +struct page_cgroup {
> > +	struct list_head lru;		/* per cgroup LRU list */
> > +	struct page *page;
> > +	struct mem_cgroup *mem_cgroup;
> > +#ifdef CONFIG_CGROUP_SWAP_LIMIT
> > +	struct mm_struct *pc_mm;
> > +#endif
> > +	atomic_t ref_cnt;		/* Helpful when pages move b/w  */
> > +					/* mapped and cached states     */
> > +	int	 flags;
> > +};
> >  
> As first impression, I don't like to increase size of this...but have no alternative
> idea.

If you really want to make the swap space subsystem and the memory subsystem
work independently each other, you can possibly introduce a new data
structure that binds pages in the swapcache and swap_cgroup.
It would be enough since only a small part of the pages are in the swapcache.

Thanks,
Hirokazu Takahashi.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
