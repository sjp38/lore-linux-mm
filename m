Date: Tue, 18 Mar 2008 10:11:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] re-define page_cgroup.
Message-Id: <20080318101110.e231351a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47DDD246.60600@cn.fujitsu.com>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080314190313.e6e00026.kamezawa.hiroyu@jp.fujitsu.com>
	<47DDD246.60600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Mar 2008 11:07:02 +0900
Li Zefan <lizf@cn.fujitsu.com> wrote:

> > Index: mm-2.6.25-rc5-mm1/include/linux/page_cgroup.h
> > ===================================================================
> > --- /dev/null
> > +++ mm-2.6.25-rc5-mm1/include/linux/page_cgroup.h
> > @@ -0,0 +1,47 @@
> > +#ifndef __LINUX_PAGE_CGROUP_H
> > +#define __LINUX_PAGE_CGROUP_H
> > +
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > +/*
> > + * page_cgroup is yet another mem_map structure for accounting  usage.
> 
>                                                       two spaces ^^
> 
thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
