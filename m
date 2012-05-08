Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 9692D6B004D
	for <linux-mm@kvack.org>; Tue,  8 May 2012 05:20:49 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so4974981wgb.26
        for <linux-mm@kvack.org>; Tue, 08 May 2012 02:20:47 -0700 (PDT)
Date: Tue, 8 May 2012 11:20:41 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH UPDATED 3/3] tracing: Provide trace events interface for
 uprobes
Message-ID: <20120508092041.GE27323@gmail.com>
References: <20120409091133.8343.65289.sendpatchset@srdronam.in.ibm.com>
 <20120409091154.8343.50489.sendpatchset@srdronam.in.ibm.com>
 <20120411103043.GB29437@linux.vnet.ibm.com>
 <20120508041229.GD30652@gmail.com>
 <1336465808.16236.13.camel@twins>
 <20120508085002.GA13272@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120508085002.GA13272@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>


* Srikar Dronamraju <srikar@linux.vnet.ibm.com> wrote:

> * Peter Zijlstra <peterz@infradead.org> [2012-05-08 10:30:08]:
> 
> > On Tue, 2012-05-08 at 06:12 +0200, Ingo Molnar wrote:
> > > FYI, this warning started to trigger in -tip, with the latest 
> > > uprobes patches:
> > > 
> > > warning: (UPROBE_EVENT) selects UPROBES which has unmet direct dependencies (UPROBE_EVENTS && PERF_EVENTS)
> > 
> > this looks to be the only UPROBE_EVENTS instance, is that a typo?
> 
> 
> I think I corrected this in the latest posting I sent on April 16th.
> 
> Ingo,
> 
> 	Since you had asked me to send the patch series again 
> after handling comments and acks, I had sent the set. [...]

Mind sending a delta patch instead? The patches are now 
reasonably well tested and don't seem to break in any functional 
way, so unless the delta patch is really ugly we should try that 
instead of rebasing the branch.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
