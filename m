From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Date: Sun, 22 Apr 2001 21:36:09 +0100
Message-ID: <i4g6etcda5nsrauuj8mrsme0mgf8bu1ein@4ax.com>
References: <o7a6ets1pf548v51tu6d357ng1o0iu77ub@4ax.com> <Pine.LNX.4.21.0104221610190.1685-100000@imladris.rielhome.conectiva>
In-Reply-To: <Pine.LNX.4.21.0104221610190.1685-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Jonathan Morton <chromi@cyberspace.org>, "Joseph A. Knapka" <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 22 Apr 2001 16:11:36 -0300 (BRST), you wrote:

>On Sun, 22 Apr 2001, James A.Sutherland wrote:
>
>> >But login was suspended because of a page fault,
>> 
>> No, login was NOT *suspended*. It's sleeping on I/O, not suspended.
>> 
>> > so potentially it will
>> >*also* get suspended for just as long as the hogs.  
>> 
>> No, it will get CPU time a small fraction of a second later, once the
>> I/O completes.
>
>You're assuming login won't have the rest of its memory (which
>it needs to do certain things) swapped out again in the time
>it waits for this page to be swapped in...
>
>... which is exactly what happens when the system is thrashing.

Except that we aren't thrashing, because the memory hog processes have
been suspended by this point and so we do have enough memory free for
login!


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
