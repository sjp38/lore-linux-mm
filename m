Date: Fri, 12 May 2006 11:08:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Status and the future of page migration
Message-Id: <20060512110825.7a49f17d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0605111841060.17334@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0605111703020.17098@schroedinger.engr.sgi.com>
	<20060512095614.7f3d2047.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0605111758400.17334@schroedinger.engr.sgi.com>
	<20060512103553.fafce5b2.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0605111841060.17334@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, ak@suse.de, pj@sgi.com, kravetz@us.ibm.com, marcelo.tosatti@cyclades.com, taka@valinux.co.jp, lee.schermerhorn@hp.com, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 11 May 2006 18:43:13 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> > > You are right but there may be system components (such as device drivers) 
> > > that require the page not to be moved. Without page migration VM_LOCKED 
> > > implies that the physical address stays the same. Kernel code may assume 
> > > that VM_LOCKED -> dont migrate.
> > > 
> > Hmm.. I think such pages should have extra refcnt to prevent migration.
> 
> refcnts are for temporary use. An extra refcnt will make page migration 
> retry until it gives up. It should not try to migrate an unmovable page.
> 
Hmm...it seems the kernel drivers assumes the pages will not moved if VM_LOCKED.
I'm not sure which is better to replace all driver's VM_LOCKED to VM_DONTMOVE or
to add VM_KEEPONMEMORY for mlock() codes and just modify the kernel core.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
