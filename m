Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B6F188D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 18:42:43 -0400 (EDT)
Received: by wwb28 with SMTP id 28so1177627wwb.26
        for <linux-mm@kvack.org>; Tue, 15 Mar 2011 15:42:40 -0700 (PDT)
Subject: Re: [PATCH v2 2.6.38-rc8-tip 4/20] 4: uprobes: Adding and remove a
 uprobe in a rb tree.
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <1300218499.2250.12.camel@laptop>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	 <20110314133444.27435.50684.sendpatchset@localhost6.localdomain6>
	 <alpine.LFD.2.00.1103151425060.2787@localhost6.localdomain6>
	 <20110315173041.GB24254@linux.vnet.ibm.com>
	 <alpine.LFD.2.00.1103151916120.2787@localhost6.localdomain6>
	 <1300218499.2250.12.camel@laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 Mar 2011 23:42:24 +0100
Message-ID: <1300228944.2565.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul
 E. McKenney" <paulmck@linux.vnet.ibm.com>

Le mardi 15 mars 2011 A  20:48 +0100, Peter Zijlstra a A(C)crit :
> On Tue, 2011-03-15 at 20:22 +0100, Thomas Gleixner wrote:
> > I am not sure if its a good idea to walk the tree
> > > as and when the tree is changing either because of a insertion or
> > > deletion of a probe.
> > 
> > I know that you cannot walk the tree lockless except you would use
> > some rcu based container for your probes. 
> 
> You can in fact combine a seqlock, rb-trees and RCU to do lockless
> walks.
> 
>   https://lkml.org/lkml/2010/10/20/160
> 
> and
> 
>   https://lkml.org/lkml/2010/10/20/437
> 
> But doing that would be an optimization best done once we get all this
> working nicely.
> 

We have such schem in net/ipv4/inetpeer.c function inet_getpeer() (using
a seqlock on latest net-next-2.6 tree), but we added a counter to make
sure a reader could not enter an infinite loop while traversing tree
(AVL tree in inetpeer case).



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
