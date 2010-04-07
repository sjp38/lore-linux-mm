Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 023656B01EE
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 02:03:52 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3763oXB006561
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 7 Apr 2010 15:03:50 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E1CC745DE79
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 15:03:49 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B1C1745DE7A
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 15:03:49 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 909A5E18006
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 15:03:49 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D402E18004
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 15:03:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Arch specific mmap attributes (Was: mprotect pgprot handling weirdness)
In-Reply-To: <1270592111.13812.88.camel@pasglop>
References: <20100406185246.7E63.A69D9226@jp.fujitsu.com> <1270592111.13812.88.camel@pasglop>
Message-Id: <20100407095145.FB70.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed,  7 Apr 2010 15:03:45 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Tue, 2010-04-06 at 19:26 +0900, KOSAKI Motohiro wrote:
> > > Ok, I see. No biggie. The main deal remains how we want to do that
> > > inside the kernel :-) I think the less horrible options here are
> > > to either extend vm_flags to always be 64-bit, or add a separate
> > > vm_map_attributes flag, and add the necessary bits and pieces to
> > > prevent merge accross different attribute vma's.
> > 
> > vma->vm_flags already have VM_SAO. Why do we need more flags?
> > At least, I dislike to add separate flags member into vma.
> > It might introduce unnecessary messy into vma merge thing.
> 
> Well, we did shove SAO in there, and used up the very last vm_flag for
> it a while back. Now I need another one, for little endian mappings. So
> I'm stuck.
> 
> But the problem goes further I believe. Archs do nowadays have quite an
> interesting set of MMU attributes that it would be useful to expose to
> some extent.

Generally speaking, It seems no good idea. desktop and server world don't
interest arch specific mmu attribute crap. because many many opensource
and ISV library don't care it. I know highend hpc and embedded have 
differenct eco-system. they might want to use such strange mmu feature.
I recommend to you are focusing popwerpc eco-system. 

I'm not against changing kernel internal. I only disagree mmu attribute
fashion will be become used widely.


> 
> Some powerpc's also provide storage keys for example and I think ARM
> have something along those lines. There's interesting cachability
> attributes too, on x86 as well. Being able to use such attributes to
> request for example a relaxed ordering mapping on x86 might be useful.
> 
> I think it basically boils down to either extend vm_flags to always be
> 64-bit, which seems to be Nick preferred approach, or introduct a
> vm_attributes with all the necessary changes to the merge code to take
> it into account (not -that- hard tho, there's only half a page of
> results in grep for these things :-)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
