From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199912092227.OAA10455@google.engr.sgi.com>
Subject: Re: Getting big areas of memory, in 2.3.x?
Date: Thu, 9 Dec 1999 14:27:26 -0800 (PST)
In-Reply-To: <Pine.LNX.4.10.9912100018160.11167-100000@chiara.csoma.elte.hu> from "Ingo Molnar" at Dec 10, 99 00:21:18 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: riel@nl.linux.org, jgarzik@mandrakesoft.com, alan@lxorguk.ukuu.org.uk, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> 
> On Thu, 9 Dec 1999, Kanoj Sarcar wrote:
> 
> > Well, at least in 2.3, kernel data (and page caches) are below 1G,
> > which means there's a lot of memory possible out there with
> > references only from user memory. Shm page references are 
> > revokable too. [...]
> 
> we already kindof replace pages, see replace_with_highmem(). Reverse ptes
> do help, but are not a necessity to get this. Neither reverse ptes, nor
> any other method guarantees that a large amount of continuous RAM can be
> allocated. Only boot-time allocation can be guaranteed.
> 
> -- mingo
> 

Unfortunately, a bunch of these drivers are loadable modules, so unless
they do some trickery, boot-time allocation does not apply for them.

A similar category of drivers would like to do this dynamically too.

For drivers that want to do this a fixed number of time at bootup,
yes, boot-time allocation is the answer ...

If I am not wrong, replace_with_highmem() replaces a page when the 
kernel is quite sure there's exactly one reference on the page, and
that is from the executing code. For the dynamic case, the problem 
is in trying to rip away unknown number of kernel/user references 
from a given page. Rmaps do not guarantee it, they just improve the 
chances of success in such problems at an affordable cost.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
