Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 228226B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 06:16:21 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5DA8sZm021404
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 04:08:54 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5DAGDja209474
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 04:16:13 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5D4Fhui019044
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 22:15:46 -0600
Date: Mon, 13 Jun 2011 15:38:35 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 0/22]  0: Uprobes patchset with perf
 probe support
Message-ID: <20110613100835.GG27130@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <1307660596.2497.1760.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1307660596.2497.1760.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

* Peter Zijlstra <peterz@infradead.org> [2011-06-10 01:03:16]:

> On Tue, 2011-06-07 at 18:28 +0530, Srikar Dronamraju wrote:
> > Please do provide your valuable comments.
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
> 

We have two options, 

Combine patches 2,3,4 and patches 6-7 and patches 9-10-11
or
Combine patches from  1 to 15 into one patch.

Please let me know your preference.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
