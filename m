Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 004D56B0096
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 01:50:00 -0500 (EST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 23 Nov 2011 23:49:58 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAO6nsLP110572
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 23:49:54 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAO6nrHq020476
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 23:49:54 -0700
Date: Thu, 24 Nov 2011 12:18:53 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: Fwd: uprobes: register/unregister probes.
Message-ID: <20111124064853.GA28065@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <hYuXv-26J-3@gated-at.bofh.it>
 <hYuXw-26J-5@gated-at.bofh.it>
 <i0o1A-7sd-9@gated-at.bofh.it>
 <fe077f71-dce6-40cf-988c-cc35bf4c7ae1@o11g2000prg.googlegroups.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <fe077f71-dce6-40cf-988c-cc35bf4c7ae1@o11g2000prg.googlegroups.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, tulasidhard@gmail.com, Jim Keniston <jkenisto@linux.vnet.ibm.com>

> 
> On Fri, 2011-11-18 at 16:37 +0530, Srikar Dronamraju wrote:
> > +#define UPROBES_HASH_SZ        13
> > +/* serialize (un)register */
> > +static struct mutex uprobes_mutex[UPROBES_HASH_SZ];
> > +#define uprobes_hash(v)        (&uprobes_mutex[((unsigned long)(v)) %\
> > +                                               UPROBES_HASH_SZ])
> 
> Was there any reason to for using this hasing scheme, say over hash.h?

There is no specific reason for choosing this hashing scheme over the
current. I just say ext4_aio_mutex in fs/ext4/ext4.h and did something
similar.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
