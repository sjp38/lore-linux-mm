Received: from pneumatic-tube.sgi.com (pneumatic-tube.sgi.com [204.94.214.22])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA26596
	for <linux-mm@kvack.org>; Thu, 6 May 1999 22:00:47 -0400
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199905070200.TAA88193@google.engr.sgi.com>
Subject: question for ia32/linux experts
Date: Thu, 6 May 1999 19:00:27 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi all,

I have a question about the RESTORE_ALL macro in
kern/arch/i386/kernel/entry.S.

The macro seems to imply that the "popl %ds", "popl %es" and
"iret" might take faults/exceptions. Exactly how can you
force these conditions in Linux? It seems to me that a user
program can not just fill in arbitrary values into ds/es
before a system call (since the processor would check the
validity of the segment register contents at load time in 
user space), forcing the kernel to take the exception path 
for the popl's.

The "iret" might have a problem, possibly if the user
invoked a system call that unmapped his code or stack, but
it seems to me that should cause page_fault from a user 
mode eip (instead of from kernel mode with the eip pointing
to the iret instruction). What else can force an exception in 
this case?

Thanks. Please CC me (kanoj@engr.sgi.com) on any replies.

Kanoj

PS - Any code snippets that trigger these conditions will be
greatly appreciated ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
