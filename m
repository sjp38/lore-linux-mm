Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F31076B003D
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 21:20:36 -0500 (EST)
Date: Thu, 3 Dec 2009 10:20:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 22/24] HWPOISON: add memory cgroup filter
Message-ID: <20091203022032.GB13587@localhost>
References: <20091202031231.735876003@intel.com> <20091202043046.519053333@intel.com> <20091202124446.GA18989@one.firstfloor.org> <20091202125842.GA13277@localhost> <4B171F35.1010908@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B171F35.1010908@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 03, 2009 at 10:15:17AM +0800, Li Zefan wrote:
> > +#ifdef	CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > +u32 hwpoison_filter_memcg;
> > +static int hwpoison_filter_task(struct page *p)
> > +{
> > +	struct mem_cgroup *mem;
> > +	struct cgroup_subsys_state *css;
> > +
> > +	if (!hwpoison_filter_memcg)
> > +		return 0;
> > +
> > +	mem = try_get_mem_cgroup_from_page(p);
> > +	if (!mem)
> > +		return -EINVAL;
> > +
> > +	css = mem_cgroup_css(mem);
> > +	if (!css)
> > +		return -EINVAL;
> > +
> 
> Here, if mem != NULL, then css won't be NULL.

Good catch, thank you!

> > +	css_put(css);
> > +	return 0;
> > +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
