Date: Thu, 29 Nov 2007 12:25:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][for -mm] per-zone and reclaim enhancements for memory
 controller take 3 [3/10] per-zone active inactive counter
Message-Id: <20071129122532.68ff4e75.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071129031937.3C86F1CFE80@siro.lan>
References: <20071127120048.ef5f2005.kamezawa.hiroyu@jp.fujitsu.com>
	<20071129031937.3C86F1CFE80@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, akpm@linux-foundation.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 29 Nov 2007 12:19:37 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> > @@ -651,10 +758,11 @@
> >  		/* Avoid race with charge */
> >  		atomic_set(&pc->ref_cnt, 0);
> >  		if (clear_page_cgroup(page, pc) == pc) {
> > +			int active;
> >  			css_put(&mem->css);
> > +			active = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
> >  			res_counter_uncharge(&mem->res, PAGE_SIZE);
> > -			list_del_init(&pc->lru);
> > -			mem_cgroup_charge_statistics(mem, pc->flags, false);
> > +			__mem_cgroup_remove_list(pc);
> >  			kfree(pc);
> >  		} else 	/* being uncharged ? ...do relax */
> >  			break;
> 
> 'active' seems unused.
> 
ok, I will post clean-up against -mm2.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
