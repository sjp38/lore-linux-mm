Received: from ucla.edu (ts49-33.dialup.bol.ucla.edu [164.67.28.234])
	by panther.noc.ucla.edu (8.9.1a/8.9.1) with ESMTP id JAA14709
	for <linux-mm@kvack.org>; Tue, 3 Apr 2001 09:04:06 -0700 (PDT)
Message-ID: <3AC9E630.58A4542D@ucla.edu>
Date: Tue, 03 Apr 2001 08:03:12 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] appling preasure to icache and dcache
Content-Type: text/plain; charset=big5
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, I'm glad somebody is working on this!  VM-time seems like a pretty
useful concept.

	I think you have a bug in your patch here: 

+       if (base > pages)       /* If the cache shrunk reset base,  The
cache
+               base = pages;    * growing applies preasure as does
expanding
+       if (free > old)          * free space - even if later shrinks */
+               base -= (base>free-old) ? free-old : base;

It looks like you unintentionally commented out two lines of code?

	I have been successfully running your patch.  But I think it needs
benchmarks.  At the very least, compile the kernel twice w/o and twice
w/ your patch and see how it changes the times.  I do not think I will
have time to do it myself anytime soon unfortunately.
	I have a 64Mb RAM machine, and the patch makes the system feel a little
bit slower when hitting the disk.  BUt that is subjective...

-BenRI
-- 
"...assisted of course by pride, for we teach them to describe the
 Creeping Death, as Good Sense, or Maturity, or Experience." 
- "The Screwtape Letters"
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
