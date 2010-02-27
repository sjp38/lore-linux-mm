Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 62F136B0047
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 19:01:18 -0500 (EST)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o1R01E8T012378
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 16:01:14 -0800
Received: from pvc21 (pvc21.prod.google.com [10.241.209.149])
	by wpaz37.hot.corp.google.com with ESMTP id o1R01DUQ005966
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 16:01:13 -0800
Received: by pvc21 with SMTP id 21so192295pvc.19
        for <linux-mm@kvack.org>; Fri, 26 Feb 2010 16:01:13 -0800 (PST)
Date: Fri, 26 Feb 2010 16:01:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
In-Reply-To: <alpine.DEB.2.00.1002261123520.7719@router.home>
Message-ID: <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com>
References: <20100215105253.GE21783@one.firstfloor.org> <20100215110135.GN5723@laptop> <alpine.DEB.2.00.1002191222320.26567@router.home> <20100220090154.GB11287@basil.fritz.box> <alpine.DEB.2.00.1002240949140.26771@router.home> <4B862623.5090608@cs.helsinki.fi>
 <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com> <alpine.DEB.2.00.1002251228140.18861@router.home> <20100226114136.GA16335@basil.fritz.box> <alpine.DEB.2.00.1002260904311.6641@router.home> <20100226155755.GE16335@basil.fritz.box>
 <alpine.DEB.2.00.1002261123520.7719@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 26 Feb 2010, Christoph Lameter wrote:

> > 1) numa memory hotadd never worked
> 
> Well Kamesan indicated that this worked if a cpu became online.
> 

That may be true, but it doesn't address hotpluggable 
ACPI_SRAT_MEM_HOT_PLUGGABLE entries for CONFIG_MEMORY_HOTPLUG_SPARSE where 
no cpus are being onlined or writing to /sys/devices/system/memory/probe 
for CONFIG_ARCH_MEMORY_PROBE.

> > 2) the rest just bitrotted because nobody tested it.
> 
> Yep. David: Can you revise the relevant portions of the patchset and
> repost it?
> 

Ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
