Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0DEDE6B0087
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 12:11:49 -0500 (EST)
Date: Thu, 28 Jan 2010 09:10:37 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Security] DoS on x86_64
In-Reply-To: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com>
Message-ID: <alpine.LFD.2.00.1001280902340.22433@localhost.localdomain>
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mathias Krause <minipli@googlemail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, security@kernel.org
List-ID: <linux-mm.kvack.org>



On Thu, 28 Jan 2010, Mathias Krause wrote:
> 
> 1. Enable core dumps
> 2. Start an 32 bit program that tries to execve() an 64 bit program
> 3. The 64 bit program cannot be started by the kernel because it can't find
> the interpreter, i.e. execve returns with an error
> 4. Generate a segmentation fault
> 5. panic

Hmm. Nothing happens for me when I try this. I just get the expected 
SIGSEGV. Can you post the oops/panic message?

I don't get a core-dump, even though it says I do:

	[torvalds@nehalem amd64_killer]$ ./run.sh 
	* look at /proc/22768/maps and press enter to continue...
	* executing ./poison...
	* that failed (No such file or directory), as expected :)
	* look at /proc/22768/maps and press enter to continue...
	* fasten your seat belt, generating segmentation fault...
	./run.sh: line 6: 22768 Segmentation fault      (core dumped) ./amd64_killer ./poison

This is with current -git (I don't have any machines around running older 
kernels), so maybe we fixed it already, of course.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
