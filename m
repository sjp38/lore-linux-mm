Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 170D16B0047
	for <linux-mm@kvack.org>; Sun,  7 Mar 2010 21:58:38 -0500 (EST)
Date: Mon, 8 Mar 2010 03:58:35 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch] slab: add memory hotplug support
Message-ID: <20100308025835.GC20695@one.firstfloor.org>
References: <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com> <alpine.DEB.2.00.1002251228140.18861@router.home> <20100226114136.GA16335@basil.fritz.box> <alpine.DEB.2.00.1002260904311.6641@router.home> <20100226155755.GE16335@basil.fritz.box> <alpine.DEB.2.00.1002261123520.7719@router.home> <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com> <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com> <20100305062002.GV8653@laptop> <c1fb08351003050447w17175bbdy15e1e9bb78c2e40@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c1fb08351003050447w17175bbdy15e1e9bb78c2e40@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Anca Emanuel <anca.emanuel@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "haicheng.li" <haicheng.li@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 05, 2010 at 02:47:04PM +0200, Anca Emanuel wrote:
> Dumb question: it is possible to hot remove the (bad) memory ? And add
> an good one ?

Not the complete DIMM, but if a specific page containing a stuck
bit or similar can be removed since 2.6.33 yes

In theory you could add new memory replacing that memory if your
hardware and your kernel supports that, but typically that's
not worth it for a few K.

> Where is the detection code for the bad module ?

Part of the code is in the kernel, part in mcelog.
It only works with ECC memory and supported systems ATM (currently
Nehalem class Intel Xeon systems)

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
