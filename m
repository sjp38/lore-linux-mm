Message-Id: <200104191947.f3JJl2M16392@eng2.sequent.com>
Reply-To: Gerrit Huizenga <gerrit@us.ibm.com>
From: Gerrit Huizenga <gerrit@us.ibm.com>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
In-reply-to: Your message of Thu, 19 Apr 2001 16:13:02 -0330.
             <Pine.LNX.4.33.0104191609500.17635-100000@duckman.distro.conectiva>
Date: Thu, 19 Apr 2001 12:47:02 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Dave McCracken <dmc@austin.ibm.com>, "James A. Sutherland" <jas88@cam.ac.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Other options to think about here include tuning/limiting a process's
working set size based on page fault frequency, adjusting the
scheduling quanta or degrading the scheduling priority of a process
when its page fault frequency is high and memory is tight, or putting
to sleep processes with a high page fault frequency.  Yes, stopping the
largest process in linux works because there are no(?) memory
allocation limits for any process, hence a process which either has
poor memory locality or simply a need for a Bigabyte of address space
will soon become the largest process.  And as memory sizes increase,
global LRU page stealing becomes less efficient, right when you need to
make quicker decisions.  Often a local page replacement algorithm or
local working space management mechanism allows the memory pigs to only
impact themselves, instead of thrashing the rest of the system.

gerrit

> On Thu, 19 Apr 2001, Rik van Riel wrote:
> [...]
> And when paging was introduced in 3bsd, process suspension
> under heavy load was preserved in the system to make sure
> the system would continue to make progress under heavy
> load instead of thrashing to a halt.
> 
> Incidentally, the "minimal working set" idea Stephen posted
> was also in 3bsd. Since this idea is good for preserving the
> forward progress of smaller programs and is extremely simple
> to implement, we probably want this too.
> 
> regards,
> 
> Rik
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
