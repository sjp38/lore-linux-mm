Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BE8298D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 13:29:51 -0400 (EDT)
From: Tom Tromey <tromey@redhat.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 0/20] 0: Inode based uprobes
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	<20110314163028.a05cec49.akpm@linux-foundation.org>
	<20110314234754.GP2499@one.firstfloor.org>
	<alpine.LFD.2.00.1103150114590.2787@localhost6.localdomain6>
	<20110315180639.GQ2499@one.firstfloor.org>
	<alpine.LFD.2.00.1103152038280.2787@localhost6.localdomain6>
	<1300219261.9910.300.camel@gandalf.stny.rr.com>
	<alpine.LFD.2.00.1103152102430.2787@localhost6.localdomain6>
Date: Wed, 16 Mar 2011 11:27:38 -0600
In-Reply-To: <alpine.LFD.2.00.1103152102430.2787@localhost6.localdomain6>
	(Thomas Gleixner's message of "Tue, 15 Mar 2011 21:09:18 +0100 (CET)")
Message-ID: <m3sjun2cxh.fsf@fleche.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Steven Rostedt <rostedt@goodmis.org>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

>> If gdb, perf, trace can and will make use of it then we have sensible
>> arguments enough to go there. If systemtap can use it as well then I
>> have no problem with that..

Yes, gdb would be able to use it.
I don't know of anybody working on it at present.

Tom

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
