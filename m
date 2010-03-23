Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 37BF06B01BF
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 14:23:01 -0400 (EDT)
Date: Tue, 23 Mar 2010 11:21:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15618] New: 2.6.18->2.6.32->2.6.33 huge
 regression in performance
Message-Id: <20100323112141.7f248f2b.akpm@linux-foundation.org>
In-Reply-To: <15090451-C292-44D6-B2BA-DCBCBEEF429D@gmail.com>
References: <bug-15618-10286@https.bugzilla.kernel.org/>
	<20100323102208.512c16cc.akpm@linux-foundation.org>
	<20100323173409.GA24845@elte.hu>
	<alpine.LFD.2.00.1003231037410.18017@i5.linux-foundation.org>
	<20100323180002.GA2965@elte.hu>
	<15090451-C292-44D6-B2BA-DCBCBEEF429D@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Anton Starikov <ant.starikov@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Mar 2010 19:03:36 +0100
Anton Starikov <ant.starikov@gmail.com> wrote:

> 
> On Mar 23, 2010, at 7:00 PM, Ingo Molnar wrote:
> >> NOTE! None of those are in 2.6.33 - they were merged afterwards. But they 
> >> are in 2.6.34-rc1 (and obviously current -git). So Anton would have to 
> >> compile his own kernel to test his load.
> > 
> > another option is to run the rawhide kernel via something like:
> > 
> > 	yum update --enablerepo=development kernel
> > 
> > this will give kernel-2.6.34-0.13.rc1.git1.fc14.x86_64, which has those 
> > changes included.
> 
> I will apply this commits to 2.6.32, I afraid current OFED (which I need also) will not work on 2.6.33+.
> 

You should be able to simply set CONFIG_RWSEM_GENERIC_SPINLOCK=n,
CONFIG_RWSEM_XCHGADD_ALGORITHM=y by hand, as I mentioned earlier?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
