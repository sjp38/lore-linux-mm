Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7B16B004D
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 16:17:14 -0500 (EST)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id o22LH8ro008821
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 21:17:08 GMT
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by spaceape8.eur.corp.google.com with ESMTP id o22LH6DV007833
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 13:17:07 -0800
Received: by pwi5 with SMTP id 5so386375pwi.6
        for <linux-mm@kvack.org>; Tue, 02 Mar 2010 13:17:05 -0800 (PST)
Date: Tue, 2 Mar 2010 13:17:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] slab: add memory hotplug support
In-Reply-To: <20100302125306.GD19208@basil.fritz.box>
Message-ID: <alpine.DEB.2.00.1003021303220.18137@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002240949140.26771@router.home> <4B862623.5090608@cs.helsinki.fi> <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com> <alpine.DEB.2.00.1002251228140.18861@router.home> <20100226114136.GA16335@basil.fritz.box>
 <alpine.DEB.2.00.1002260904311.6641@router.home> <20100226155755.GE16335@basil.fritz.box> <alpine.DEB.2.00.1002261123520.7719@router.home> <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com> <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com>
 <20100302125306.GD19208@basil.fritz.box>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Mar 2010, Andi Kleen wrote:

> The patch looks far more complicated than my simple fix.
> 
> Is more complicated now better?
> 

If you still believe these are "fixes," then perhaps you don't fully 
understand the issue: slab completely lacked memory hotplug support when a 
node is either being onlined or offlined that do not have hotadded or 
hotremoved cpus.  It's as simple as that.

To be fair, my patch may appear more complex because it implements full 
memory hotplug support so that the nodelists are properly drained and 
freed when the same memory regions you onlined for memory hot-add are now 
offlined.  Notice, also, how it touches no other slab code as implementing 
new support for something shouldn't.  There is no need for additional 
hacks to be added in other slab code if you properly allocate and 
initialize the nodelists for the memory being added before it is available 
for use by the kernel.

If you'd test my patch out on your setup, that would be very helpful.  I 
can address any additional issues that you may undercover if you post the 
oops while doing either memory online or offline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
