Message-Id: <200104191557.LAA28201@multics.mit.edu>
Subject: Re: Want to allocate almost all the memory with no swap
In-Reply-To: Your message of "Thu, 19 Apr 2001 17:58:38 +0200."
             <Pine.LNX.4.21.0104191755240.10028-100000@guarani.imag.fr>
Date: Thu, 19 Apr 2001 11:57:45 -0400
From: Kev <klmitch@MIT.EDU>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Simon Derr <Simon.Derr@imag.fr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Well, I have removed as many processes deamons as I could, and there are
> not many left.
> But under both 2.4.2 and 2.2.17 (with swap on)I get, when I run my
> program:
> 
> mlockall: Cannot allocate memory

mlockall() requires root priviledges.
-- 
Kevin L. Mitchell <klmitch@mit.edu>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
