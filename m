Date: Thu, 3 Jul 2008 10:42:57 -0700 (PDT)
From: Doug Thompson <norsk5@yahoo.com>
Subject: Re: Failing memory auto-hotremove support?
In-Reply-To: <486CC533.6080302@buttersideup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Message-ID: <90872.19606.qm@web50110.mail.re2.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tim Small <tim@buttersideup.com>, bluesmoke-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--- Tim Small <tim@buttersideup.com> wrote:

> Hello,
> 
> I just noticed that there is memory hotplug / hotremove support in the 
> kernel.org kernel now.

cool, good to hear. Now I (or others) need some cycles to review it and mod EDAC to utilize it if
possible and/or provide feedback to the memory guys

> 
> I was thinking that it may be desirable (e.g. on large NUMA systems) to 
> automatically trigger the removal of memory modules (or just take a 
> section of the memory module out of use, if applicable), if a memory 
> module exceeded a pre-set correctable error rate (or RIGHT-NOW, if an 
> uncorrectable memory error was detected).

THAT is exactly what one of the goals of EDAC (then bluesmoke) had in mind years ago, but there
was no easy mechanism, within the kernel, to perform those types of controls (take a section of
memory out of commision).

When you have a NUMA node with 64 or 128 gigbabytes of memory and have 5,000 such nodes, rebooting
in not a very good thing to do. 

BUT being able to detect a bad DIMM (or a pair) via EDAC and then notify the memory subsystem to
de-activate that DIMM (pair) from active use is GREAT feature to have. The node graciously handles
the downed memory and stays UP running that big cluster task, all the while notifying the admin
that a DIMM needs replacement at the next maintaince cycle.

doug t

> 
> Tim.
> 


W1DUG

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
