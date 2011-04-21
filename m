Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D81AF8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:49:50 -0400 (EDT)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by bombadil.infradead.org with esmtps (Exim 4.72 #1 (Red Hat Linux))
	id 1QCy0j-0003RB-Cd
	for linux-mm@kvack.org; Thu, 21 Apr 2011 17:49:49 +0000
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1QCy0i-0003WQ-7X
	for linux-mm@kvack.org; Thu, 21 Apr 2011 17:49:48 +0000
Subject: Re: [PATCH v3 2.6.39-rc1-tip 7/26]  7: x86: analyze instruction
 and determine fixups.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110421173120.GJ10698@linux.vnet.ibm.com>
References: 
	 <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
	 <20110401143348.15455.68644.sendpatchset@localhost6.localdomain6>
	 <1303219751.7181.101.camel@gandalf.stny.rr.com>
	 <20110421173120.GJ10698@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 21 Apr 2011 19:52:25 +0200
Message-ID: <1303408345.2035.161.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 2011-04-21 at 23:01 +0530, Srikar Dronamraju wrote:
> 
> Sometimes, the user might try registering a probe at a valid file +
> valid offset + valid consumer; but an instruction that we cant probe.
> Then trying to figure why its failing would be very hard. 

Uhm, how about failing to create the probe to begin with?

You can even do that in userspace as you can inspect the DSO you're
going to probe (and pretty much have to, since you'll have to pass the
kernel a fd to hand it the proper inode).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
