Message-ID: <3C6ACC76.6A3D3A36@scs.ch>
Date: Wed, 13 Feb 2002 21:28:38 +0100
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: __pa() vs. virt_to_phys()
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Is there any reason to use __pa() rather than virt_to_phys() or vice versa?

On i386 virt_to_phys() is just a function that returns the value returned by __pa(); on Alpha virt_to_phys() is a function that subtracts IDENT_ADDR from the argument,
whereas __pa() is a macro that subtracts PAGE_OFFSET from its argument - however PAGE_OFFSET and IDENT_ADDR expand to the same value; on Sparc virt_to_phys() is a macro
that expands to __pa().

So the two things look to be pretty much the same on different platforms - is there any reason
for having __pa() as well as virt_to_phys(), and which one is to be used by device drivers?

thanks for your help
regards
Martin
--
Supercomputing System AG          email: maletinsky@scs.ch
Martin Maletinsky                 phone: +41 (0)1 445 16 05
Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
CH-8005 Zurich


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
