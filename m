From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
Date: Thu, 19 Apr 2001 08:08:29 +0100
Message-ID: <6m3tdtkpcf22j0pq28is7b7c6digfapg06@4ax.com>
References: <Pine.LNX.4.30.0104190031190.20939-100000@fs131-224.f-secure.com> <Pine.LNX.4.21.0104182311370.1685-100000@imladris.rielhome.conectiva>
In-Reply-To: <Pine.LNX.4.21.0104182311370.1685-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Szabolcs Szakacsits <szaka@f-secure.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Apr 2001 23:11:59 -0300 (BRST), you wrote:

>On Thu, 19 Apr 2001, Szabolcs Szakacsits wrote:
>> On Wed, 18 Apr 2001, James A. Sutherland wrote:
>> > >How you want to avoid "deadlocks" when running processes have
>> > >dependencies on suspended processes?
>> > If a process blocks waiting for another, the thrashing will be
>> > resolved.
>> 
>> This is a big simplification, e.g. not if it polls [not poll(2)].
>
>If it sits there in a loop, the rest of the memory that process
>uses can be swapped out ;)

Also, if your program is busy-waiting for another to complete in that
way, you need to feed it into /dev/null and get another program :-)


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
