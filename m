From: "Cannizzaro, Emanuele" <ecannizzaro@mtc.ricardo.com>
Reply-To: "Cannizzaro, Emanuele" <ecannizzaro@mtc.ricardo.com>
Content-Type: text/plain;
  charset="iso-8859-15"
Subject: memory allocation on linux
Date: Wed, 7 Aug 2002 16:19:07 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20020807152152Z26523-20094+91@kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org, ebiederm+eric@ccr.net, leechin@mail.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I am writing to you regarding your experience to address a huge amount of 
memory on linux using the brk() function.

I am running a program called nastran (v2001) on a pc with redhat 7.2. This 
machine has got 2GB of disk spacebut  when I set the amount of memory to be 
used by nastran to a value bigger than 900 mb I get this fatal error message.

Process Id = 28179
idalloc: dynamic allocation failed - brk: Cannot allocate memory
   requested size: 402653184 words (1572864 kbytes)
   starting address:           0x0a300000 ( 170917888)
   maximum address requested:  0x6a300080 (1781530752)
 08:08:18  MAINAL: *** OPEN CORE MEMORY ALLOCATION FAILED *** ERROR =         
 1
 08:08:18  MAINAL: *** MEMORY REQUESTED =    402653184 ***
 08:08:18  MAINAL: *** PROCESSING TERMINATED ***
 08:08:18  Analysis complete  8
STOP OPEN CORE Allocation Failed statement executed

I have no access to the source code of the program and therefore I would need 
a patch to the memory allocation.

how can this problem be fixed?

Thanks in advance for your help

Emanuele Cannizzaro
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
