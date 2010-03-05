Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CB3436B004D
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 09:11:23 -0500 (EST)
Date: Fri, 5 Mar 2010 08:11:00 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] slab: add memory hotplug support
In-Reply-To: <c1fb08351003050447w17175bbdy15e1e9bb78c2e40@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1003050808390.32229@router.home>
References: <alpine.DEB.2.00.1002240949140.26771@router.home>  <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com>  <alpine.DEB.2.00.1002251228140.18861@router.home>  <20100226114136.GA16335@basil.fritz.box>  <alpine.DEB.2.00.1002260904311.6641@router.home>
  <20100226155755.GE16335@basil.fritz.box>  <alpine.DEB.2.00.1002261123520.7719@router.home>  <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com>  <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com>  <20100305062002.GV8653@laptop>
 <c1fb08351003050447w17175bbdy15e1e9bb78c2e40@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Anca Emanuel <anca.emanuel@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "haicheng.li" <haicheng.li@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 5 Mar 2010, Anca Emanuel wrote:

> Dumb question: it is possible to hot remove the (bad) memory ? And add
> an good one ?

Under certain conditions this is possible. If the bad memory was modified
then you have a condition that requires termination of all processes that
are using the memory. If its the kernel then you need to reboot.

If the memory contains a page from disk then the memory can be moved
elsewhere.

If you can clean up a whole range like that then its possible to replace
the memory.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
