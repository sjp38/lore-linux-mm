Date: Wed, 27 Aug 2008 08:55:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/14]  delay page_cgroup freeing
Message-Id: <20080827085501.291f79b6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48B3ED0C.6050409@linux.vnet.ibm.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822203324.409635c6.kamezawa.hiroyu@jp.fujitsu.com>
	<48B3ED0C.6050409@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Aug 2008 17:16:20 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > +/*
> > + * per-cpu slot for freeing page_cgroup in lazy manner.
> > + * All page_cgroup linked to this list is OBSOLETE.
> > + */
> > +struct mem_cgroup_sink_list {
> > +	int count;
> > +	struct page_cgroup *next;
> > +};
> 
> Can't we reuse the lru field in page_cgroup to build a list? Do we need them on
> the memory controller LRU if they are obsolete? I want to do something similar
> for both additions and deletions - reuse pagevec style, basically. I am OK,
> having a list as well, in that case we can just reuse the LRU pointer.
> 
reusing page_cgroup->lru is not a choice because this patch is for avoid
locking on mz->lru_lock (and kfree).
But using vector can be a choice. I'll try in the next version.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
