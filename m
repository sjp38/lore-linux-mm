Date: Fri, 20 Apr 2001 09:48:16 -0500
From: Dave McCracken <dmc@austin.ibm.com>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Message-ID: <10520000.987778096@baldur>
In-Reply-To: <Pine.LNX.4.30.0104201203280.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Friday, April 20, 2001 14:14:29 +0200 Szabolcs Szakacsits 
<szaka@f-secure.com> wrote:

> What about the simplest case when one process thrasing? You suspend it
> continuously from time to time so it won't finish e.g. in 10 minutes but
> in 1 hour.

Isn't one prcess thrashing sort of like one hand clapping? :)

Seriously, the state we're talking about is when the running processes in 
the machine collectively want significantly more memory than is available, 
and none of them can make real progress.  Suspending one or more of them 
for a few seconds will actually improve throughput and responsiveness of 
the entire system.  As Rik has said, this has been in pretty much all 
flavors of Unix since the early days, and it has been proven to be 
effective.

I'm not saying there aren't other things we can do with working set 
tracking that could help push out the point where the machine thrashes, but 
at some point all those mechanisms will be overwhelmed, and process 
suspension is a good last resort.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmc@austin.ibm.com                                      T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
