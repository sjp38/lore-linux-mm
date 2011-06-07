Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 970E76B00E7
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 09:39:02 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp02.au.ibm.com (8.14.4/8.13.1) with ESMTP id p57DX6HI023027
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:33:06 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p57DcIZA1196238
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:38:18 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p57Dcvdj025150
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:38:58 +1000
Date: Tue, 7 Jun 2011 19:08:53 +0530
From: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 20/22] 20: perf: perf interface for
	uprobes
Message-ID: <20110607133853.GC9949@in.ibm.com>
Reply-To: ananth@in.ibm.com
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6> <20110607130216.28590.5724.sendpatchset@localhost6.localdomain6> <20110607133039.GA4929@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110607133039.GA4929@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 07, 2011 at 09:30:39AM -0400, Christoph Hellwig wrote:
> On Tue, Jun 07, 2011 at 06:32:16PM +0530, Srikar Dronamraju wrote:
> > 
> > Enhances perf probe to user space executables and libraries.
> > Provides very basic support for uprobes.
> 
> Nice.  Does this require full debug info for symbolic probes,
> or can it also work with simple symbolc information?

It works only with symbol information for now.
It doesn't (yet) know how to use debuginfo :-)

Ananth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
