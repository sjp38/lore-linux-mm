Date: Fri, 26 Sep 2008 10:17:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 9/12] memcg allocate all page_cgroup at boot
Message-Id: <20080926101754.91e64254.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1222368047.15523.81.camel@nimitz>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20080925153206.281243dc.kamezawa.hiroyu@jp.fujitsu.com>
	<1222368047.15523.81.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Thu, 25 Sep 2008 11:40:47 -0700
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Thu, 2008-09-25 at 15:32 +0900, KAMEZAWA Hiroyuki wrote:
> > @@ -949,6 +953,11 @@ struct mem_section {
> > 
> >         /* See declaration of similar field in struct zone */
> >         unsigned long *pageblock_flags;
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > +       /* see page_cgroup.h */
> > +       struct page_cgroup *page_cgroup;
> > +       unsigned long pad;
> > +#endif
> >  };
> 
> I thought the use of this variable was under the
> 
> 	+#ifdef CONFIG_FLAT_NODE_MEM_MAP
> 
> options.  Otherwise, we unconditionally bloat mem_section, right?
> 
Hmmm......Oh, yes ! nice catch.

Thanks, I'll fix.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
