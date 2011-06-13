Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DC0966B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 04:57:52 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5D8RFP2010475
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 04:27:15 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5D8vpW1782554
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 04:57:51 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5D8vnI1010115
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 04:57:50 -0400
Date: Mon, 13 Jun 2011 14:20:17 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 2/22]  2: uprobes: Breakground page
 replacement.
Message-ID: <20110613085017.GC27130@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607125835.28590.25476.sendpatchset@localhost6.localdomain6>
 <1307660607.2497.1771.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1307660607.2497.1771.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

* Peter Zijlstra <peterz@infradead.org> [2011-06-10 01:03:27]:

> On Tue, 2011-06-07 at 18:28 +0530, Srikar Dronamraju wrote:
> > +       ret = anon_vma_prepare(vma);
> > +       if (ret)
> > +               goto unlock_out;
> 
> You just leaked new_page.

Right, Will fix this.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
