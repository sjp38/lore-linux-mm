Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 994886B010F
	for <linux-mm@kvack.org>; Tue,  8 May 2012 05:01:20 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 8 May 2012 03:01:19 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 5898E1FF001F
	for <linux-mm@kvack.org>; Tue,  8 May 2012 03:01:15 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4891E1l188040
	for <linux-mm@kvack.org>; Tue, 8 May 2012 03:01:14 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4891BSC025414
	for <linux-mm@kvack.org>; Tue, 8 May 2012 03:01:13 -0600
Date: Tue, 8 May 2012 14:20:02 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH UPDATED 3/3] tracing: Provide trace events interface
 for uprobes
Message-ID: <20120508085002.GA13272@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120409091133.8343.65289.sendpatchset@srdronam.in.ibm.com>
 <20120409091154.8343.50489.sendpatchset@srdronam.in.ibm.com>
 <20120411103043.GB29437@linux.vnet.ibm.com>
 <20120508041229.GD30652@gmail.com>
 <1336465808.16236.13.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1336465808.16236.13.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

* Peter Zijlstra <peterz@infradead.org> [2012-05-08 10:30:08]:

> On Tue, 2012-05-08 at 06:12 +0200, Ingo Molnar wrote:
> > FYI, this warning started to trigger in -tip, with the latest 
> > uprobes patches:
> > 
> > warning: (UPROBE_EVENT) selects UPROBES which has unmet direct dependencies (UPROBE_EVENTS && PERF_EVENTS)
> 
> this looks to be the only UPROBE_EVENTS instance, is that a typo?


I think I corrected this in the latest posting I sent on April 16th.

Ingo,

	Since you had asked me to send the patch series again after
handling comments and acks, I had sent the set. At that time, I had
handled this change as part of a comment from Stephen Boyd.  I had
mentioned this in the changelog.

	Would it be possible for you to accept the patches from 
https://lkml.org/lkml/2012/4/16/109
with message id: 
Message-Id: <20120416091936.19174.2641.sendpatchset@srdronam.in.ibm.com> 

Currently you seem to have picked from 
https://lkml.org/lkml/2012/4/11/117

--
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
