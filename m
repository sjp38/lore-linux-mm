From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Date: Sun, 22 Apr 2001 21:58:09 +0100
Message-ID: <2ch6etcc6mvtt83g45gu5dta6ftp8kudoe@4ax.com>
References: <ssf6etkhgrc2ejgcv22ophdj7pb5fbifbk@4ax.com> <Pine.LNX.4.21.0104221740380.1685-100000@imladris.rielhome.conectiva>
In-Reply-To: <Pine.LNX.4.21.0104221740380.1685-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Jonathan Morton <chromi@cyberspace.org>, "Joseph A. Knapka" <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 22 Apr 2001 17:41:41 -0300 (BRST), you wrote:

>On Sun, 22 Apr 2001, James A.Sutherland wrote:
>
>> >>How exactly will your approach solve the two process case, yet still
>> >>keeping the processes running properly?
>> >
>> >It will allocate one process it's entire working set in physical RAM, 
>> 
>> Which one?
>
>A random one. And after some time you switch, suspending the
>first process and letting the other one run.

We've crossed wires here: I know that's how the suspension approach
works, I'm talking about the "working set" approach - which to me,
sounds more likely to give both processes 50Mb each, and spend the
next six weeks grinding the disks to powder!

>Note that I have code for this on my system here, I'll put it
>online soon.

Cool - I'll finally be able to open files in Acrobat Reader without
having one finger on the reset button :-)


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
