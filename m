Received: from daisy.net ([213.129.29.129]) by mail.daisy.dk
          (Netscape Messaging Server 3.62)  with ESMTP id 1827
          for <linux-mm@kvack.org>; Sat, 30 Dec 2000 15:30:50 +0100
Message-ID: <3A4DEDBA.2214FB06@daisy.net>
Date: Sat, 30 Dec 2000 15:14:18 +0100
From: Henrik Witt-Hansen <bean@daisy.net>
MIME-Version: 1.0
Subject: Problem on AMD Elan SC520 CDP
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi..  

This seems to be the best place to ask this..??


I am currently working on the AMD Elan SC520 dev. board. Had Linux
2.2.14-2.2.17 running without any problems the last 5 month.

We now need to migrate to linux 2.4.x (allthough still a test-kernel,
_i_know_, please do not bug me, but my boss!). And the 2.4.0-test12
kernel hangs, right after the "uncompressing linux.....ok" message..

I have traced the problem to the first lines in 'start_kernel()' in
init/main.c. It happens randomly and is not directly linked to printk or
other instructions..   Seems to happen when doing a 'mov..' with an
address as source (f.ex. the linux_banner string), but if that
instruction is removed, the hang just happens a little bit later on..  I
have used a big delay before any instructions in start_kernel (done in
assembler source, not the c file..) and even after 30 sec. execution
continues, so it seems that it is not a timing related problem, or some
interrupt 'thing'.

The bug seems to be introduced between 2.3.22 (works allmost fine, pci
detect crach and burn, but no hang) and 2.3.23 where all the new mm
stuff made it into the kernel. (this is why i ask this here...)
Could it be some pagefault related issue, possible a need for
adjustments to initialize a slightly buggy sc520 processor ??  (is aware
of other such 'features')


Does anybody have an idea to what might be the problem, any suggestions
of where to start looking (besides AMD errata's which i am still waiting
for..!).

AMD claims that the sc520 processor is an 5x86, but it seems to be more
like Intel 486 on the inside.. ??



	Thanks in advance for any helpfull advice..


		Henrik

-- 
  ***      Henrik Witt-Hansen  -  System developer     ***
  ****      (+45) 2840 8502  or  (+45) 3395 2983      ****
  Daisy Net A/S, Hulgardsvej 133, DK-2400, (+45) 3395 2980
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
