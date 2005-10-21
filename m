Date: Fri, 21 Oct 2005 09:39:17 +0200 (CEST)
From: Simon Derr <Simon.Derr@bull.net>
Subject: Re: [PATCH 4/4] Swap migration V3: sys_migrate_pages interface
In-Reply-To: <435896CA.1000101@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.61.0510210927140.17098@openx3.frec.bull.fr>
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
 <20051020225955.19761.53060.sendpatchset@schroedinger.engr.sgi.com>
 <4358588D.1080307@jp.fujitsu.com> <Pine.LNX.4.61.0510210901380.17098@openx3.frec.bull.fr>
 <435896CA.1000101@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Simon Derr <Simon.Derr@bull.net>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, Mike Kravetz <kravetz@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Magnus Damm <magnus.damm@gmail.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Oct 2005, KAMEZAWA Hiroyuki wrote:

> 
> 
> > Christoph Lameter wrote:
> > 
> > > > > +	/* Is the user allowed to access the target nodes? */
> > > > > +	if (!nodes_subset(new, cpuset_mems_allowed(task)))
> > > > > +		return -EPERM;
> > > > > +
> > 
> > > How about this ?
> > > +cpuset_update_task_mems_allowed(task, new);    (this isn't implemented
> > > now
> 
> *new* is already guaranteed to be the subset of current mem_allowed.
> Is this violate the permission ?

Oh, I misunderstood your mail.
I thought you wanted to automatically add extra nodes to the cpuset,
but you actually want to do just the opposite, i.e restrict the nodemask 
for this task to the one passed to sys_migrate_pages(). Is that right ?

(If not, ignore the rest of this message)

Maybe sometimes the user would be interested in migrating all the 
existing pages of a process, but not change the policy for the future ?

	Simon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
