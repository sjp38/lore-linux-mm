Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id BBF126B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:23:59 -0400 (EDT)
Date: Wed, 25 Apr 2012 16:22:41 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC 0/6] uprobes: kill uprobes_srcu/uprobe_srcu_id
Message-ID: <20120425142241.GA18319@redhat.com>
References: <20120405222024.GA19154@redhat.com> <20120414111637.GB24688@gmail.com> <20120416113124.GA25464@linux.vnet.ibm.com> <20120416144116.GA6745@redhat.com> <20120425125239.GA2889@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120425125239.GA2889@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On 04/25, Srikar Dronamraju wrote:
>
> I applied the patches and ran all my tests.
> Everything works as expected.

Thanks a lot Srikar.

I'll resend this series with some cleanups. Probably we do not need
is_swbp_at_addr_fast, we can check mm == current->mm in read_opcode()
as Peter suggests. Plus I'll try to make the MMF_UPROBE changes we
discussed. And a couple of really minor and off-topic cleanups.

But I'll wait until we have all pending patches in -tip to avoid
the unnecessary noise at this stage.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
