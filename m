From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: Want to allocate almost all the memory with no swap
Date: Thu, 19 Apr 2001 17:11:34 +0100
Message-ID: <0g3udt09u4dmcvhh11q6mnm7ithcjmbup4@4ax.com>
References: <Pine.LNX.4.21.0104191755240.10028-100000@guarani.imag.fr> <200104191557.LAA28201@multics.mit.edu>
In-Reply-To: <200104191557.LAA28201@multics.mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kev <klmitch@MIT.EDU>
Cc: Simon Derr <Simon.Derr@imag.fr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001 11:57:45 -0400, you wrote:

>> Well, I have removed as many processes deamons as I could, and there are
>> not many left.
>> But under both 2.4.2 and 2.2.17 (with swap on)I get, when I run my
>> program:
>> 
>> mlockall: Cannot allocate memory
>
>mlockall() requires root priviledges.

Uh... if calling mlockall() as a non-root user gives that error,
someone should fix the error returned...

Sorry, I should have mentioned that it required you to be root!


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
