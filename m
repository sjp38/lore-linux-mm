Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DA9F76B00BC
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 02:20:45 -0500 (EST)
Received: by bke17 with SMTP id 17so1586530bke.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 23:20:42 -0800 (PST)
Message-ID: <1322032836.1298.39.camel@edumazet-laptop>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Nov 2011 08:20:36 +0100
In-Reply-To: <20111123071349.GA1671@x4.trippels.de>
References: <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121173556.GA1673@x4.trippels.de>
	 <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121185215.GA1673@x4.trippels.de>
	 <20111121195113.GA1678@x4.trippels.de> <1321907275.13860.12.camel@pasglop>
	 <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>
	 <alpine.DEB.2.00.1111212105330.19606@router.home>
	 <1321948113.27077.24.camel@edumazet-laptop>
	 <1321950432.27077.27.camel@edumazet-laptop>
	 <20111123071349.GA1671@x4.trippels.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: Christoph Lameter <cl@linux.com>, Christian Kujau <lists@nerdbynature.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

Le mercredi 23 novembre 2011 A  08:13 +0100, Markus Trippelsdorf a
A(C)crit :
> On 2011.11.22 at 09:27 +0100, Eric Dumazet wrote:
> > Le mardi 22 novembre 2011 A  08:48 +0100, Eric Dumazet a A(C)crit :
> > 
> > > For x86, I wonder if our !X86_FEATURE_CX16 support is correct on SMP
> > > machines.
> > > 
> > 
> > 
> > By the way, I wonder why we still emit this_cpu_cmpxchg16b_emu() code
> > and calls when compiling a kernel for a cpu implementing cmpxchg16b
> > 
> > (CONFIG_MCORE2=y)
> 
> Yeah, it's strange (CONFIG_MK8):
> 
> ffffffff811058b0 <__kmalloc>:
> ...
> ffffffff8110594f:       48 8d 4a 04             lea    0x4(%rdx),%rcx
> ffffffff81105953:       49 8b 1c 04             mov    (%r12,%rax,1),%rbx
> ffffffff81105957:       4c 89 e0                mov    %r12,%rax
> ffffffff8110595a:       e8 11 70 10 00          callq  ffffffff8120c970 <this_cpu_cmpxchg16b_emu>
> ffffffff8110595f:       66 66 90                data32 xchg %ax,%ax
> ffffffff81105962:       84 c0                   test   %al,%al
> ffffffff81105964:       74 c6                   je     ffffffff8110592c <__kmalloc+0x7c>
> ...
> 

This is patched at bootime (asm alternative)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
