Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A0BAA6B0078
	for <linux-mm@kvack.org>; Sun,  7 Mar 2010 22:06:54 -0500 (EST)
Date: Mon, 8 Mar 2010 04:06:50 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch] slab: add memory hotplug support
Message-ID: <20100308030650.GD20695@one.firstfloor.org>
References: <alpine.DEB.2.00.1002251228140.18861@router.home> <20100226114136.GA16335@basil.fritz.box> <alpine.DEB.2.00.1002260904311.6641@router.home> <20100226155755.GE16335@basil.fritz.box> <alpine.DEB.2.00.1002261123520.7719@router.home> <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com> <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com> <20100305062002.GV8653@laptop> <c1fb08351003050447w17175bbdy15e1e9bb78c2e40@mail.gmail.com> <alpine.DEB.2.00.1003050808390.32229@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003050808390.32229@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Anca Emanuel <anca.emanuel@gmail.com>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "haicheng.li" <haicheng.li@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> Under certain conditions this is possible. If the bad memory was modified
> then you have a condition that requires termination of all processes that
> are using the memory. If its the kernel then you need to reboot.
> 
> If the memory contains a page from disk then the memory can be moved
> elsewhere.
> 
> If you can clean up a whole range like that then its possible to replace
> the memory.

Typically that's not possible because of the way DIMMs are interleaved --
the to be freed areas would be very large, and with a specific size
there are always kernel or unmovable user areas areas in the way.

In general on Linux hot DIMM replacement only works if the underlying
platform does it transparently (e.g. support memory RAID and chipkill) 
and you have enough redundant memory for it.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
