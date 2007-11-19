Date: Mon, 19 Nov 2007 10:37:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memory controller per zone patches take 2 [2/10]
 add nid/zid function for page_cgroup
Message-Id: <20071119103754.28c9c107.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <473EB141.4000005@linux.vnet.ibm.com>
References: <20071116191107.46dd523a.kamezawa.hiroyu@jp.fujitsu.com>
	<20071116191635.2c141c38.kamezawa.hiroyu@jp.fujitsu.com>
	<473EB141.4000005@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

On Sat, 17 Nov 2007 14:45:45 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >  mm/memcontrol.c |   10 ++++++++++
> >  1 file changed, 10 insertions(+)
> > 
> > Index: linux-2.6.24-rc2-mm1/mm/memcontrol.c
> > ===================================================================
> > --- linux-2.6.24-rc2-mm1.orig/mm/memcontrol.c
> > +++ linux-2.6.24-rc2-mm1/mm/memcontrol.c
> > @@ -135,6 +135,16 @@ struct page_cgroup {
> >  #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
> >  #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
> > 
> > +static inline int page_cgroup_nid(struct page_cgroup *pc)
> > +{
> > +	return page_to_nid(pc->page);
> > +}
> > +
> > +static inline int page_cgroup_zid(struct page_cgroup *pc)
> > +{
> > +	return page_zonenum(pc->page);
> 
> page_zonenum returns zone_type, isn't it better we carry the
> type through to the caller?
> 
seems resonable. ok. I will fix.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
