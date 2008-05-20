Date: Tue, 20 May 2008 19:56:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/3] memcg: per node information
Message-Id: <20080520195640.6e1c1da9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48329AE0.2010505@cn.fujitsu.com>
References: <20080520180552.601da567.kamezawa.hiroyu@jp.fujitsu.com>
	<20080520180955.70aa5459.kamezawa.hiroyu@jp.fujitsu.com>
	<48329AE0.2010505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 20 May 2008 17:33:20 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> >  static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
> > Index: mm-2.6.26-rc2-mm1/Documentation/controllers/memory_files.txt
> > ===================================================================
> > --- mm-2.6.26-rc2-mm1.orig/Documentation/controllers/memory_files.txt
> > +++ mm-2.6.26-rc2-mm1/Documentation/controllers/memory_files.txt
> > @@ -74,3 +74,13 @@ Files under memory resource controller a
> >    (write)
> >    Reset to 0.
> >  
> > +* memory.numa_stat
> > +
> > +  This file appears only when the kernel is configured as NUMA.
> > +
> > +  (read)
> > +  Show per-node accounting information of acitve/inactive pages.
> > +  formated as following.
> 
> formatted
> 
> > +  nodeid  total active inactive
> 
> 2 spaces?  ^^
> 

Thanks, will fix.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
