From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
Date: Thu, 19 Apr 2001 19:47:12 +0100
Message-ID: <cfcudto0dln5tvehbgt4pecqf7i6nfuirf@4ax.com>
References: <Pine.LNX.4.30.0104182315010.20939-100000@fs131-224.f-secure.com> <11530000.987705299@baldur>
In-Reply-To: <11530000.987705299@baldur>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmc@austin.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001 13:34:59 -0500, you wrote:

>--On Wednesday, April 18, 2001 23:32:25 +0200 Szabolcs Szakacsits 
><szaka@f-secure.com> wrote:
>
>> Sorry, your comment isn't convincing enough ;) Why do you think
>> "arbitrarily" (decided exclusively by the kernel itself) suspending
>> processes (that can be done in user space anyway) would help?
>>
>> Even if you block new process creation and memory allocations (that's
>> also not nice since it can be done by resource limits) why you think
>> situation will ever get better i.e. processes release memory?
>>
>> How you want to avoid "deadlocks" when running processes have
>> dependencies on suspended processes?
>
>I think there's a semantic misunderstanding here.  If I understand Rik's 
>proposal right, 

Well, it was my proposal when I first said it :-)

>he's not talking about completely suspending a process ala 
>SIGSTOP.  He's talking about removing it from the run queue for some small 
>length of time (ie a few seconds, probably) during which all the other 
>processes can make progress.  

Rik and I are both proposing that, AFAICS; however it's implemented
(SIGSTOP or direct tweaking of the run queue; I prefer the former,
since I think it could be done more neatly) you just suspend the
process for a couple of seconds, then resume it (and suspend someone
else if the thrashing continues).

>This kind of suspension won't be noticeable 
>to users/administrators or permanently block dependent processes.  In fact, 
>it should make the system appear more responsive than one in a thrashing 
>state.

Indeed. It would certainly help with the usual test-case for such
things ("make -j 50" or similar): you'll end up with 40 gcc processes
being frozen at once, allowing the other 10 to complete first.


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
