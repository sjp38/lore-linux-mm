Date: Thu, 12 Jun 2008 14:00:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/2] memcg: hardwall hierarhcy for memcg
Message-Id: <20080612140048.0051feb2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080611162423.3ba183b4.randy.dunlap@oracle.com>
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
	<20080604140329.8db1b67e.kamezawa.hiroyu@jp.fujitsu.com>
	<20080611162423.3ba183b4.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Thank you. will fix.

-Kame

On Wed, 11 Jun 2008 16:24:23 -0700
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> On Wed, 4 Jun 2008 14:03:29 +0900 KAMEZAWA Hiroyuki wrote:
> 
> > ---
> >  Documentation/controllers/memory.txt |   27 +++++-
> >  mm/memcontrol.c                      |  156 ++++++++++++++++++++++++++++++++++-
> >  2 files changed, 178 insertions(+), 5 deletions(-)
> > 
> 
> > Index: temp-2.6.26-rc2-mm1/Documentation/controllers/memory.txt
> > ===================================================================
> > --- temp-2.6.26-rc2-mm1.orig/Documentation/controllers/memory.txt
> > +++ temp-2.6.26-rc2-mm1/Documentation/controllers/memory.txt
> > @@ -237,12 +237,37 @@ cgroup might have some charge associated
> >  tasks have migrated away from it. Such charges are automatically dropped at
> >  rmdir() if there are no tasks.
> >  
> > -5. TODO
> > +5. Hierarchy Model
> > +  the kernel supports following kinds of hierarchy models.
> 
>      The kernel supports the following kinds ....
> 
> > +  (your middle-ware may support others based on this.)
> 
>      (Your
> > +
> > +  5-a. Independent Hierarchy
> > +  There are no relationship between any cgroups, even among a parent and
> 
>            is
> 
> > +  children. This is the default mode. To use this hierarchy, write 0
> > +  to root cgroup's memory.hierarchy_model
> > +  echo 0 > .../memory.hierarchy_model.
> > +
> > +  5-b. Hardwall Hierarchy.
> > +  The resource has to be moved from the parent to the child before use it.
> 
>                                                                       using it.
> 
> > +  When a child's limit is set to 'val', val of the resource is moved from
> > +  the parent to the child. the parent's usage += val.
> 
>                               The parent's usage is incremented by val.
> (if that's what you mean)
> 
> > +  The amount of children's usage is reported by the file
> > +
> > +  - memory.assigned_to_child
> > +
> > +  This policy doesn't provide sophisticated automatic resource balancing in
> > +  the kernel. But this is very good for strict resource isolation. Users
> 
>          kernel, but this ...
> 
> > +  can get high predictability of behavior of applications if this is used
> > +  under proper environments.
> > +
> > +
> > +6. TODO
> >  
> >  1. Add support for accounting huge pages (as a separate controller)
> >  2. Make per-cgroup scanner reclaim not-shared pages first
> >  3. Teach controller to account for shared-pages
> >  4. Start reclamation when the limit is lowered
> > +   (this is already done in Hardwall Hierarchy)
> >  5. Start reclamation in the background when the limit is
> >     not yet hit but the usage is getting closer
> > --
> 
> ---
> ~Randy
> '"Daemon' is an old piece of jargon from the UNIX operating system,
> where it referred to a piece of low-level utility software, a
> fundamental part of the operating system."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
