Received: from austin.ibm.com (netmail1.austin.ibm.com [9.53.250.96])
	by mg03.austin.ibm.com (AIX4.3/8.9.3/8.9.3) with ESMTP id NAA16300
	for <linux-mm@kvack.org>; Thu, 19 Apr 2001 13:36:59 -0500
Received: from baldur.austin.ibm.com (baldur.austin.ibm.com [9.53.230.118])
	by austin.ibm.com (AIX4.3/8.9.3/8.9.3) with ESMTP id NAA30676
	for <linux-mm@kvack.org>; Thu, 19 Apr 2001 13:35:03 -0500
Received: from baldur (localhost.austin.ibm.com [127.0.0.1])
	by baldur.austin.ibm.com (8.12.0.Beta7/8.11.3) with ESMTP id f3JIZ4Wm013145
	for <linux-mm@kvack.org>; Thu, 19 Apr 2001 13:35:04 -0500
Date: Thu, 19 Apr 2001 13:34:59 -0500
From: Dave McCracken <dmc@austin.ibm.com>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
Message-ID: <11530000.987705299@baldur>
In-Reply-To: <Pine.LNX.4.30.0104182315010.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Wednesday, April 18, 2001 23:32:25 +0200 Szabolcs Szakacsits 
<szaka@f-secure.com> wrote:

> Sorry, your comment isn't convincing enough ;) Why do you think
> "arbitrarily" (decided exclusively by the kernel itself) suspending
> processes (that can be done in user space anyway) would help?
>
> Even if you block new process creation and memory allocations (that's
> also not nice since it can be done by resource limits) why you think
> situation will ever get better i.e. processes release memory?
>
> How you want to avoid "deadlocks" when running processes have
> dependencies on suspended processes?

I think there's a semantic misunderstanding here.  If I understand Rik's 
proposal right, he's not talking about completely suspending a process ala 
SIGSTOP.  He's talking about removing it from the run queue for some small 
length of time (ie a few seconds, probably) during which all the other 
processes can make progress.  This kind of suspension won't be noticeable 
to users/administrators or permanently block dependent processes.  In fact, 
it should make the system appear more responsive than one in a thrashing 
state.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmc@austin.ibm.com                                      T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
