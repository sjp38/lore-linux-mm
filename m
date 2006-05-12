Date: Thu, 11 May 2006 20:21:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Status and the future of page migration
In-Reply-To: <20060512110825.7a49f17d.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0605112017040.17677@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0605111703020.17098@schroedinger.engr.sgi.com>
 <20060512095614.7f3d2047.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0605111758400.17334@schroedinger.engr.sgi.com>
 <20060512103553.fafce5b2.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0605111841060.17334@schroedinger.engr.sgi.com>
 <20060512110825.7a49f17d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, ak@suse.de, pj@sgi.com, kravetz@us.ibm.com, marcelo.tosatti@cyclades.com, taka@valinux.co.jp, lee.schermerhorn@hp.com, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 12 May 2006, KAMEZAWA Hiroyuki wrote:

> Hmm...it seems the kernel drivers assumes the pages will not moved if VM_LOCKED.
> I'm not sure which is better to replace all driver's VM_LOCKED to VM_DONTMOVE or
> to add VM_KEEPONMEMORY for mlock() codes and just modify the kernel core.

We could add a MCL_DONTMOVE to mlockall() because we need also some way 
for user space to pin pages and then add a VM_DONTMOVE to the vm 
flags. Then do a global search through the kernel source and replace 
VM_LOCKED in the drivers with VM_DONTMOVE. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
