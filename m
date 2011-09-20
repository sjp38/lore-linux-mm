Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B9F179000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 11:33:12 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8KF2GIm030871
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 11:02:16 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8KFWwsO098552
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 11:33:01 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8KFWkh4019966
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 12:32:49 -0300
Date: Tue, 20 Sep 2011 20:49:03 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 0/26]   Uprobes patchset with perf
 probe support
Message-ID: <20110920151903.GA22802@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920133401.GA28550@infradead.org>
 <20110920141204.GC6568@linux.vnet.ibm.com>
 <20110920142843.GA9995@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110920142843.GA9995@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

* Christoph Hellwig <hch@infradead.org> [2011-09-20 10:28:43]:

> On Tue, Sep 20, 2011 at 07:42:04PM +0530, Srikar Dronamraju wrote:
> > I could use any other inode/file/mapping based sleepable lock that is of
> > higher order than mmap_sem. Can you please let me know if we have
> > alternatives.
> 
> Please do not overload unrelated locks for this, but add a specific one.
> 
> There's two options:
> 
>  (a) add it to the inode (conditionally)
>  (b) use global, hashed locks
> 
> I think (b) is good enough as adding/removing probes isn't exactly the
> most critical fast path.
> 

Agree, I will replace the i_mutex with a uprobes specific hash locks.
I will make this change as part of next patchset.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
