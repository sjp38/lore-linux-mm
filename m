Date: Wed, 4 Jun 2008 15:54:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/2] memcg: hardwall hierarhcy for memcg
Message-Id: <20080604155416.d2899386.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4846394D.9010805@cn.fujitsu.com>
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
	<20080604140329.8db1b67e.kamezawa.hiroyu@jp.fujitsu.com>
	<4846394D.9010805@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 04 Jun 2008 14:42:21 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > Hard-Wall hierarchy support for memcg.
> >  - new member hierarchy_model is added to memcg.
> > 
> > Only root cgroup can modify this only when there is no children.
> > 
> > Adds following functions for supporting HARDWALL hierarchy.
> >  - try to reclaim memory at the change of "limit".
> >  - try to reclaim all memory at force_empty
> >  - returns resources to the parent at destroy.
> > 
> > Changelog v2->v3
> >  - added documentation.
> >  - hierarhcy_model parameter is added.
> > 
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > ---
> >  Documentation/controllers/memory.txt |   27 +++++-
> >  mm/memcontrol.c                      |  156 ++++++++++++++++++++++++++++++++++-
> >  2 files changed, 178 insertions(+), 5 deletions(-)
> > 
> > Index: temp-2.6.26-rc2-mm1/mm/memcontrol.c
> > ===================================================================
> > --- temp-2.6.26-rc2-mm1.orig/mm/memcontrol.c
> > +++ temp-2.6.26-rc2-mm1/mm/memcontrol.c
> > @@ -137,6 +137,8 @@ struct mem_cgroup {
> >  	struct mem_cgroup_lru_info info;
> >  
> >  	int	prev_priority;	/* for recording reclaim priority */
> > +
> > +	int	hierarchy_model; /* used hierarchical policy */
> 
> hierarchy_model can be a global value instead of per cgroup value.
> 
Ah, Hmm...yes. thank you for pointing out.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
