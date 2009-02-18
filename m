Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2036D6B009A
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 16:27:33 -0500 (EST)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1ILPI7D021469
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 16:25:18 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1ILRUDc149706
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 16:27:31 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1ILRUGO015486
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 16:27:30 -0500
Subject: Re: What can OpenVZ do?
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090218181644.GD19995@elte.hu>
References: <20090212114207.e1c2de82.akpm@linux-foundation.org>
	 <1234475483.30155.194.camel@nimitz>
	 <20090212141014.2cd3d54d.akpm@linux-foundation.org>
	 <20090213105302.GC4608@elte.hu> <1234817490.30155.287.camel@nimitz>
	 <20090217222319.GA10546@elte.hu> <1234909849.4816.9.camel@nimitz>
	 <20090218003217.GB25856@elte.hu> <1234917639.4816.12.camel@nimitz>
	 <20090218051123.GA9367@x200.localdomain>  <20090218181644.GD19995@elte.hu>
Content-Type: text/plain
Date: Wed, 18 Feb 2009 13:27:27 -0800
Message-Id: <1234992447.26788.12.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, Nathan Lynch <nathanl@austin.ibm.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, hpa@zytor.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Wed, 2009-02-18 at 19:16 +0100, Ingo Molnar wrote:
> Nothing motivates more than app designers complaining about the 
> one-way flag.
> 
> Furthermore, it's _far_ easier to make a one-way flag SMP-safe. 
> We just set it and that's it. When we unset it, what do we about 
> SMP races with other threads in the same MM installing another 
> non-linear vma, etc.

After looking at this for file descriptors, I have to really agree with
Ingo on this one, at least as far as the flag is concerned.  I want to
propose one teeny change, though:  I think the flag should be
per-resource.

We should have one flag in mm_struct, one in files_struct, etc...  The
task_is_checkpointable() function can just query task->mm, task->files,
etc...  This gives us nice behavior at clone() *and* fork that just
works.

I'll do this for files_struct and see how it comes out so you can take a
peek.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
