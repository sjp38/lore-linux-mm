Date: Thu, 11 May 2006 18:43:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Status and the future of page migration
In-Reply-To: <20060512103553.fafce5b2.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0605111841060.17334@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0605111703020.17098@schroedinger.engr.sgi.com>
 <20060512095614.7f3d2047.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0605111758400.17334@schroedinger.engr.sgi.com>
 <20060512103553.fafce5b2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, ak@suse.de, pj@sgi.com, kravetz@us.ibm.com, marcelo.tosatti@cyclades.com, taka@valinux.co.jp, lee.schermerhorn@hp.com, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 12 May 2006, KAMEZAWA Hiroyuki wrote:

> > What precise information would be needed? We could return the current node 
> > information in a status array. Right I forgot to include the status array 
> > that returns success / or failure of the call. The status array would 
> > allow to find out the failure reason for each page.
> > 
> I'm sorry I missed "F.e. user space..."
> BTW, we can get statistics of off-node-access for each vma now ?

You can do that by programming the PMU (IA64) to notify you on each long 
latency memory access.

> > You are right but there may be system components (such as device drivers) 
> > that require the page not to be moved. Without page migration VM_LOCKED 
> > implies that the physical address stays the same. Kernel code may assume 
> > that VM_LOCKED -> dont migrate.
> > 
> Hmm.. I think such pages should have extra refcnt to prevent migration.

refcnts are for temporary use. An extra refcnt will make page migration 
retry until it gives up. It should not try to migrate an unmovable page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
