Message-Id: <200003241958.OAA03128@ccure.karaya.com>
Subject: Re: madvise (MADV_FREE) 
In-Reply-To: Your message of "Fri, 24 Mar 2000 17:08:28 GMT."
             <20000324170828.C3693@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Fri, 24 Mar 2000 14:58:10 -0500
From: Jeff Dike <jdike@karaya.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>, lk@tantalophile.demon.co.uk
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The i386 not-user-mode kernel

I usually call that the native kernel :-)

lk@tantalophile.demon.co.uk said:
> certainly uses the accessed and dirty bits. What do you think
> pte_young does?

sct@redhat.com said:
> It uses the accessed bit to perform page aging, and it uses the dirty
> bit to distinguish between private and shared pages on writable
> private vmas, or to mark dirty shared pages on shared vmas.

I should have thought a little before making that post.  When I did the 
user-mode port, I didn't have to provide any special support for maintaining 
the non-protection bits (should I be?).  I essentially stole the i386 
pgtable.h and pgalloc.h to get the bits and macros, and that's about it.

Everything appears to work fine, so my conclusion (without delving into the 
i386 code too deeply) was that the upper kernel maintained them itself without 
any particular help from the hardware.

Is this correct?  Should I be dealing with the non-protection bits in the arch 
layer?

				Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
