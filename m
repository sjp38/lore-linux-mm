Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2196B004A
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 18:59:49 -0400 (EDT)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1QUoCY-000668-Ey
	for linux-mm@kvack.org; Thu, 09 Jun 2011 22:59:46 +0000
Subject: Re: [PATCH v4 3.0-rc2-tip 0/22]  0: Uprobes patchset with perf
 probe support
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
References: 
	 <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 10 Jun 2011 01:03:16 +0200
Message-ID: <1307660596.2497.1760.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2011-06-07 at 18:28 +0530, Srikar Dronamraju wrote:
> Please do provide your valuable comments.

Your patch split-up is complete crap. I'm about to simply fold all of
them just to be able to read anything.

The split-up appears to do its best to make it absolutely impossible to
get a sane overview of things, tons of things are out of order, either
it relies on future patches filling out things or modifies stuff in
previous patches.

Its a complete pain to read..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
