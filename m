From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: Want to allocate almost all the memory with no swap
Date: Thu, 19 Apr 2001 18:31:38 +0100
Message-ID: <p58udtg6lm1i3j4s6iq434af3mtfbske4j@4ax.com>
References: <de3udt4pee8l6lrr2k33h65m1b4srb74ek@4ax.com> <Pine.LNX.4.21.0104191833070.10083-100000@guarani.imag.fr>
In-Reply-To: <Pine.LNX.4.21.0104191833070.10083-100000@guarani.imag.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Simon Derr <Simon.Derr@imag.fr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001 18:46:00 +0200 (MEST), you wrote:

>> >Well, I have removed as many processes deamons as I could, and there are
>> >not many left.
>> >But under both 2.4.2 and 2.2.17 (with swap on)I get, when I run my
>> >program:
>> >
>> >mlockall: Cannot allocate memory
>> 
>> Hrm? Can you trim the consumption a bit - try cutting a big chunk out,
>> like 64 Mb, and see if it works then?
>> 
>If I ask much less memory it works.. but has no interest.
>
>In fact I a call mlockall() _before_ doing my big malloc, it works even
>when I ask 240 megs, but:
>-Under 2.2.17, quickly the kernel kills my process

Gagh?! What signal? Any oops/core/panic?

>-Under 2.4.2, kswapd again eats the CPU:

Does it eat it continually, or do you get it back after a while? You
SHOULD see it chewing up all the CPU until it has evicted 240 Mb worth
of pages, then going back to sleep...


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
