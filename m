From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199907141720.KAA11365@google.engr.sgi.com>
Subject: Re: SHM implementation in 2.2.x
Date: Wed, 14 Jul 1999 10:20:23 -0700 (PDT)
In-Reply-To: <378CA731.846F7580@sap-ag.de> from "Thomas Hiller" at Jul 14, 99 05:05:21 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Hiller <thomas.hiller@sap-ag.de>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> What are the real limits in using SHM ?
> I looked through the code and are quite lost.
> There seem to be a 24 bit limit in ID + IDX bits (shmparam.h). Is this
> due to the fact that the other 8 bits are used for SWP_TYPE ?
> What is the limit for SHMMAX and what advantage is there to leave it at
> a lower limit ?
>

Assuming you are talking about ia32 include/asm-i386/shmparam.h.
Look at my patch posted at 

	http://humbolt.nl.linux.org/lists/linux-mm/1999-06/msg00071.html

that tries to clear up some of the confusion. As far as I can see, 
SHMMAX really does not have a limit, except that it has to be a 
signed int.

> What we need are many big shared segments (say 4000 * 1 GB). Is this
> possible with the current implementation ? Or what must be changed ?
> Only SHM_ID_BITS and SHMMAX ?
>

You can bump up SHMMAX to 1Gb, but you can not cross 2Gb since
shmget() is prototyped to take an "int" size. I have a small patch
that actually lets SHMMAX go up to TASK_SIZE, unfortunately 
reporting tools like ipcs get confused (not a big deal if you know
what you are getting into ...) For the 4000 segments, try bumping
up SHMMNI.

Feel free to get in touch with me via private email if you need help.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
