Received: from geocities.com (IDENT:roman@romix.kullen.RWTH-Aachen.DE [137.226.79.61])
	by kullensrv.kullen.rwth-aachen.de (8.9.3/8.9.3/K20.07.99) with ESMTP id NAA29229
	for <Linux-MM@kvack.org>; Fri, 13 Aug 1999 13:30:44 +0200
Message-ID: <37B41E00.4D55F876@geocities.com>
Date: Fri, 13 Aug 1999 13:30:40 +0000
From: Roman Levenstein <romix@geocities.com>
MIME-Version: 1.0
Subject: Strange  memory allocation error in 2.2.11
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I've a very strange error on my RedHat 5.2 with 2.2.11 kernel.

I'm writing a program , which actively uses garbage collection,
implemented in
a separate library(it scans stack, heap, etc. and relies on the system,
when trying to determine start and end addresses of these memory areas ,
but doesn't contain any assembler low-level code).
 
It works just fine for kernels <=2.2.9 , but since I've installed 2.2.11
garbage collector behaves very strange:
sometimes it crashes , sometimes it loops forever , sometimes it works
Ok.

I think there's a problem with MM in this new kernel. To be sure , I
reloaded my 
computer with the old (2.2.3) version of kernel and everything works
correctly.

Are there any changes in MM for 2.2.11 , which require recompilation of
user programs? 

What other reasons can lead to such effect?

Thanks in advance,
 Roman Levenstein
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
