Message-ID: <A33AEFDC2EC0D411851900D0B73EBEF766E100@NAPA>
From: Hua Ji <hji@netscreen.com>
Subject: mtsr and mfsr?
Date: Thu, 7 Jun 2001 10:16:25 -0700 
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-user@lists.linuxppc.org, linuxppc-embedded@lists.linuxppc.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Folks,

Need help, please. Thanks in advance.

I am working on a board with MPC 750 for an internal products development.

I currently can no problem set up the BATs and enable MMU for memory
management. 

However, when I set up the segment registers, I am confused and stuck here.

I was trying to clear and write some values into those 15 sr registers by
using **mtsr**.

But looks like it doesn't work. The testing I did looks like follows:

-------------
#define RESET 0 
li %r3, RESET;

sync
isync
mtsr sr0, %r3
isync
sync

mfsr %r3, sr0
bl uart_print
...
-------------

The console print-out shows that I didn't write into srs with the zero
value, except
sr1 and sr5. All the rest sr(s) value is still not back to zero.

Did I miss something?

Thanks,

Mike



 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
