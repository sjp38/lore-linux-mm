Date: Fri, 21 Oct 2005 09:27:00 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 4/4] Swap migration V3: sys_migrate_pages interface
In-Reply-To: <435896CA.1000101@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.62.0510210926120.23328@schroedinger.engr.sgi.com>
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
 <20051020225955.19761.53060.sendpatchset@schroedinger.engr.sgi.com>
 <4358588D.1080307@jp.fujitsu.com> <Pine.LNX.4.61.0510210901380.17098@openx3.frec.bull.fr>
 <435896CA.1000101@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Simon Derr <Simon.Derr@bull.net>, Andrew Morton <akpm@osdl.org>, Mike Kravetz <kravetz@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Magnus Damm <magnus.damm@gmail.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Oct 2005, KAMEZAWA Hiroyuki wrote:

> > > How about this ?
> > > +cpuset_update_task_mems_allowed(task, new);    (this isn't implemented
> > > now
> 
> *new* is already guaranteed to be the subset of current mem_allowed.
> Is this violate the permission ?
 
Could the cpuset_mems_allowed(task) function update the mems_allowed if 
needed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
