From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200009031726.KAA90541@google.engr.sgi.com>
Subject: Re: Stuck at 1GB again
Date: Sun, 3 Sep 2000 10:26:48 -0700 (PDT)
In-Reply-To: <20000902115032.A2764@top.worldcontrol.com> from "brian@worldcontrol.com" at Sep 02, 2000 11:50:32 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: brian@worldcontrol.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> 
> Some time ago, the list was very helpful in solving my programs
> failing at the limit of real memory rather than expanding into
> swap under linux 2.2.
>

I can;t say what your actual problem is, but in previous experiments,
I have seen these as the main cause:

1. shortage of real memory (ram + swap). I don't think this is your
problem.

2. resource limit problems: some resource limits were defined as 
"int/long" instead of "unsigned int/long", but these should have
been fixed.

3. inability of malloc to find a contiguous range of virtual space in
userland: this depends on libraries used etc, that eat up chunks of
the user space. This might be your problem. (Hint: code a while(1)
loop before any malloc happens in your program, then use "cat 
/proc/pid/maps", where pid is the pid of your running program, to
see the user space virtual address allocation; you might not see
a contiguous 3Gb chunk for malloc).

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
