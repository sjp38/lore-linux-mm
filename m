Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 800BB6001DA
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 16:59:36 -0500 (EST)
Date: Thu, 28 Jan 2010 13:58:33 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Security] DoS on x86_64
In-Reply-To: <2BCD2997-7101-4BFF-82CC-A5EC2F4F8E9E@googlemail.com>
Message-ID: <alpine.LFD.2.00.1001281354230.22433@localhost.localdomain>
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <alpine.LFD.2.00.1001280902340.22433@localhost.localdomain> <2BCD2997-7101-4BFF-82CC-A5EC2F4F8E9E@googlemail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mathias Krause <minipli@googlemail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, security@kernel.org
List-ID: <linux-mm.kvack.org>



On Thu, 28 Jan 2010, Mathias Krause wrote:
> > I don't get a core-dump, even though it says I do:
> > 
> > 	[torvalds@nehalem amd64_killer]$ ./run.sh
> > 	* look at /proc/22768/maps and press enter to continue...
> > 	* executing ./poison...
> > 	* that failed (No such file or directory), as expected :)
> > 	* look at /proc/22768/maps and press enter to continue...
> 
> Have you looked at /proc/PID/maps at this point? On our machine the [vdso] was
> gone and [vsyscall] was there instead -- at an 64 bit address of course.

Yup. That's the behavior I see - except I see the [vdso] thing in both 
cases.

So I agree that it has become a 64-bit process, and that the whole 
personality crap is buggy. 

I just don't see the crash.

> Since this is a production server I would rather stick to a stable kernel and
> just pick the commit that fixes the issue. Can you please tell me which one
> that may be?

I'd love to be able to say that it's been fixed in so-and-so, but since I 
don't know what the oops is, I have a hard time even guessing _whether_ it 
has actually been fixed or not, or whether the reason I don't see it is 
something else totally unrelated.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
