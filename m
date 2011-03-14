Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C1B118D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:08:17 -0400 (EDT)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2EGwG6s001231
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 12:58:19 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 2190638C803B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:08:13 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EH8Gp6329682
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:08:16 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EH8DEc004954
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 14:08:16 -0300
Date: Mon, 14 Mar 2011 22:32:27 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 1/20]  1: mm: Move replace_page() to
 mm/memory.c
Message-ID: <20110314170227.GN24254@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133413.27435.67467.sendpatchset@localhost6.localdomain6>
 <1300112195.9910.92.camel@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1300112195.9910.92.camel@gandalf.stny.rr.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Steven Rostedt <rostedt@goodmis.org> [2011-03-14 10:16:35]:

> On Mon, 2011-03-14 at 19:04 +0530, Srikar Dronamraju wrote:
> > User bkpt will use background page replacement approach to insert/delete
> > breakpoints. Background page replacement approach is based on
> > replace_page. Hence replace_page() loses its static attribute.
> > 
> 
> Just a nitpick, but since replace_page() is being moved, could you
> specify that in the change log. Something like:
> 
> "Hence, replace_page() is moved from ksm.c into memory.c and its static
> attribute is removed."

Okay, Will take care to add the moved from ksm.c into memory.c in the
next version of patchset.

> 
> I like to see in the change log "move x to y" when that is actually
> done, because it is hard to see if anything actually changed when code
> is moved. Ideally it is best to move code in one patch and make the

As discussed in IRC, moving and removing the static attribute had to
be one patch so that mm/ksm.c compiles correctly. The other option we
have is to remove the static attribute first and then moving the
function.

> change in another. If you do cut another version of this patch set,
> could you do that. This alone is not enough to require a new release.
> 

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
