Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 29C8D8D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 15:32:44 -0400 (EDT)
Subject: Re: [PATCH v2 2.6.38-rc8-tip 7/20]  7: uprobes: store/restore
 original instruction.
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <1300217432.2250.0.camel@laptop>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	 <20110314133522.27435.45121.sendpatchset@localhost6.localdomain6>
	 <20110314180914.GA18855@fibrous.localdomain>
	 <20110315092247.GW24254@linux.vnet.ibm.com>
	 <1300211862.2203.302.camel@twins> <20110315185841.GH3410@balbir.in.ibm.com>
	 <1300217432.2250.0.camel@laptop>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Tue, 15 Mar 2011 15:32:40 -0400
Message-ID: <1300217560.9910.296.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: balbir@linux.vnet.ibm.com, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, 2011-03-15 at 20:30 +0100, Peter Zijlstra wrote:
> On Wed, 2011-03-16 at 00:28 +0530, Balbir Singh wrote:

> > I accept the blame and am willing to fix anything incorrect found in
> > the code. 
> 
> :-), ok sounds right, just wasn't entirely obvious when having a quick
> look.

Does that mean we should be adding a comment there?

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
