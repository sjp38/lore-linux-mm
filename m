Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 641B06B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 00:05:59 -0500 (EST)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 22 Nov 2011 00:05:39 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAM54dP9312826
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 00:04:39 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAM54CMO004676
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 22:04:14 -0700
Date: Tue, 22 Nov 2011 10:33:30 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 3.2-rc2 0/30] uprobes patchset with perf probe
 support
Message-ID: <20111122050330.GA24807@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>

Hi Ingo, Thomas, Linus, Stephen, Peter,

> This patchset resolves most of the comments on the previous posting
> (https://lkml.org/lkml/2011/11/10/408) patchset applies on top of
> commit cfcfc9eca2b
> 
> This patchset depends on bulkref patch from Paul McKenney
> https://lkml.org/lkml/2011/11/2/365 and enable interrupts before
> calling do_notify_resume on i686 patch
> https://lkml.org/lkml/2011/10/25/265.
> 
> uprobes git is hosted at git://github.com/srikard/linux.git
> with branch inode_uprobes_v32rc2.
> (The previous patchset posted to lkml has been rebased to 3.2-rc2 is also
> available at branch inode_uprobes_v32rc2_prev. This is to help the
> reviewers of the previous patchsets to quickly identify the changes.)
> 
> Uprobes Patches
> This patchset implements inode based uprobes which are specified as
> <file>:<offset> where offset is the offset from start of the map.

Given that uprobes has been reviewed several times on LKML and all
comments till now have been addressed, can we push uprobes into either
-tip or -next. This will help people to test and give more feedback and
also provide a way for it to be pushed into 3.3. This also helps in
resolving and pushing fixes faster.

If you have concerns, can you please voice them?

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
