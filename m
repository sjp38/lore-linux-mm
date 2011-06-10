Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 329B76B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 02:15:23 -0400 (EDT)
Message-ID: <4DF1B668.2020002@hitachi.com>
Date: Fri, 10 Jun 2011 15:15:04 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 3.0-rc2-tip 0/22]  0: Uprobes patchset with perf probe
 support
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6> <1307660596.2497.1760.camel@laptop>
In-Reply-To: <1307660596.2497.1760.camel@laptop>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

(2011/06/10 8:03), Peter Zijlstra wrote:
> On Tue, 2011-06-07 at 18:28 +0530, Srikar Dronamraju wrote:
>> Please do provide your valuable comments.
> 
> Your patch split-up is complete crap. I'm about to simply fold all of
> them just to be able to read anything.
> 
> The split-up appears to do its best to make it absolutely impossible to
> get a sane overview of things, tons of things are out of order, either
> it relies on future patches filling out things or modifies stuff in
> previous patches.
> 
> Its a complete pain to read..


Maybe for the part of uprobe itself, you are right.
But I hope tracing/perf parts are separated from that.

Thanks,

-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
