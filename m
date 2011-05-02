Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 16A706B0022
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:44:41 -0400 (EDT)
Date: Mon, 2 May 2011 16:44:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2011-04-29 - wonky VmRSS and VmHWM values after swapping
Message-Id: <20110502164430.eb7d451d.akpm@linux-foundation.org>
In-Reply-To: <8185.1304347042@localhost>
References: <201104300002.p3U02Ma2026266@imap1.linux-foundation.org>
	<49683.1304296014@localhost>
	<8185.1304347042@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Mon, 02 May 2011 10:37:22 -0400
Valdis.Kletnieks@vt.edu wrote:

> On Sun, 01 May 2011 20:26:54 EDT, Valdis.Kletnieks@vt.edu said:
> > On Fri, 29 Apr 2011 16:26:16 PDT, akpm@linux-foundation.org said:
> > > The mm-of-the-moment snapshot 2011-04-29-16-25 has been uploaded to
> > > 
> > >    http://userweb.kernel.org/~akpm/mmotm/
> >  
> > Dell Latitude E6500 laptop, Core2 Due P8700, 4G RAM, 2G swap.Z86_64 kernel.
> > 
> > I was running a backup of the system to an external USB hard drive.
> 
> Is a red herring.  Am seeing it again, after only 20 minutes of uptime, and so
> far I've only gotten 1.2G or so into the 4G ram (2.5G still free), and never
> touched swap yet.
> 
> Aha! I have a reproducer (found while composing this note).  /bin/su will
> reliably trigger it (4 tries out of 4, launching from a bash shell that itself
> has sane VmRSS and VmHWM values).  So it's a specific code sequence doing it
> (probably one syscall doing something quirky).
> 
> Now if I could figure out how to make strace look at the VmRSS after each
> syscall, or get gdb to do similar.  Any suggestions?  Am open to perf/other
> solutions as well, if anybody has one handy...
> 

hm, me too.  After boot, hald has a get_mm_counter(mm, MM_ANONPAGES) of
0xffffffffffff3c27.  Bisected to Pater's
mm-extended-batches-for-generic-mmu_gather.patch, can't see how it did
that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
