Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5C24A6B007D
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 17:18:47 -0500 (EST)
Date: Thu, 28 Jan 2010 14:18:01 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Security] DoS on x86_64
In-Reply-To: <FE79E0D4-6783-432E-8A2A-D239B113FD85@googlemail.com>
Message-ID: <alpine.LFD.2.00.1001281415420.22433@localhost.localdomain>
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <alpine.LFD.2.00.1001280902340.22433@localhost.localdomain> <2BCD2997-7101-4BFF-82CC-A5EC2F4F8E9E@googlemail.com> <alpine.LFD.2.00.1001281354230.22433@localhost.localdomain>
 <FE79E0D4-6783-432E-8A2A-D239B113FD85@googlemail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mathias Krause <minipli@googlemail.com>
Cc: linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, security@kernel.org
List-ID: <linux-mm.kvack.org>



On Thu, 28 Jan 2010, Mathias Krause wrote:
> > 
> > So I agree that it has become a 64-bit process, and that the whole
> > personality crap is buggy.
> 
> So it's not really fixed yet :)

Right. Peter looked at it at some point. But there's a big difference 
between "we have always had problems with that execve() mess" and "we have 
a nasty DoS that can be triggered by regular users", and the two may well 
have independent fixes.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
