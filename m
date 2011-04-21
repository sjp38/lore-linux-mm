Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB388D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:22:04 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@hack.frob.com>
Subject: Re: [PATCH v3 2.6.39-rc1-tip 12/26] 12: uprobes: slot allocation
 for uprobes
In-Reply-To: Eric Paris's message of  Thursday, 21 April 2011 10:45:33 -0400 <1303397133.1708.41.camel@unknown001a4b0c2895>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
	<20110401143457.15455.64839.sendpatchset@localhost6.localdomain6>
	<1303145171.32491.886.camel@twins>
	<20110419062654.GB10698@linux.vnet.ibm.com>
	<BANLkTimw7dV9_aSsrUfzwSdwr6UwZDsRwg@mail.gmail.com>
	<20110421141125.GG10698@linux.vnet.ibm.com>
	<1303397133.1708.41.camel@unknown001a4b0c2895>
Message-Id: <20110421161442.61A532C15B@topped-with-meat.com>
Date: Thu, 21 Apr 2011 09:14:42 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Paris <eparis@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Eric Paris <eparis@parisplace.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, sds@tycho.nsa.gov

> Unrelated note: I'd prefer to see that page be READ+EXEC only once it
> has been mapped into the victim task.  Obviously the portion of the code
> that creates this page and sets up the instructions to run is going to
> need write.  Maybe this isn't feasible.  Maybe this magic pages gets
> written a lot even after it's been mapped in.  But I'd rather, if
> possible, know that my victim tasks didn't have a WRITE+EXEC page
> available......

AIUI the page never really needs to be writable in the page tables.  It's
never written from user mode.  It's only written by kernel code, and that
can use a separate momentary kmap to do its writing.


Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
