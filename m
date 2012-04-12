Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 1A8B86B010C
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 08:42:24 -0400 (EDT)
Message-ID: <4F86CDA3.3000302@hitachi.com>
Date: Thu, 12 Apr 2012 21:42:11 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] tracing: Modify is_delete, is_return from int
 to bool
References: <20120409091133.8343.65289.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20120409091133.8343.65289.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

(2012/04/09 18:11), Srikar Dronamraju wrote:
> From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> 
> is_delete and is_return can take utmost 2 values and are better of
> being a boolean than a int. There are no functional changes.
> 
> Acked-by: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

OK, this should be changed.

Acked-by: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>

Thank you,

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
