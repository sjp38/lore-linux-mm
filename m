Date: Thu, 21 Aug 2008 12:58:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH -mm 0/7] memcg: lockless page_cgroup v1
Message-Id: <20080821125842.7a8a073e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48ACE2D5.8090106@linux.vnet.ibm.com>
References: <20080819173014.17358c17.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820185306.e897c512.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820194108.e76b20b3.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820200006.a152c14c.kamezawa.hiroyu@jp.fujitsu.com>
	<20080821111740.49f99038.kamezawa.hiroyu@jp.fujitsu.com>
	<48ACE2D5.8090106@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: LKML <linux-kernel@vger.kernel.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, ryov@valinux.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Aug 2008 09:06:53 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > I'd like to rewrite force_empty to move all usage to "default" cgroup.
> > There are some reasons.
> > 
> > 1. current force_empty creates an alive page which has no page_cgroup.
> >    This is bad for routine which want to access page_cgroup from page.
> >    And this behavior will be an issue of race condition in future.    
> > 2. We can see amount of out-of-control usage in default cgroup.
> > 
> > But to do this, I'll have to avoid "hitting limit" in default cgroup.
> > I'm now wondering to make it impossible to set limit to default cgroup.
> > (will show as a patch in the next version of series.) 
> > Does anyone have an idea ?
> > 
> 
> Hi, Kamezawa-San,
> 
> The definition of default-cgroup would be root cgroup right? I would like to
> implement hierarchies correctly in order to define the default-cgroup (it could
> be a parent of the child cgroup for example).
> 

Ah yes, "root" cgroup, now.
I need trash-can-cgroup somewhere for force_empty. Accounted-in-trash-can is
better than accounter by no one. Once we change the behavior, we can have 
another choices of improvements.

1. move account information to the parent cgroup.
2. move account information to user-defined trash-can cgroup.

As first step, I'd like to start from "root" cgroup. We can improve behavior in
step-by-step manner as we've done.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
