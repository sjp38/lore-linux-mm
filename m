Received: from elf.cs.tu-berlin.de (pokam@elf.cs.tu-berlin.de [130.149.31.104])
	by mail.cs.tu-berlin.de (8.9.1/8.9.1) with ESMTP id KAA16842
	for <linux-mm@kvack.org>; Fri, 17 Sep 1999 10:12:29 +0200 (MET DST)
Date: Fri, 17 Sep 1999 10:12:26 +0200 (MET DST)
From: Gilles Pokam <pokam@cs.tu-berlin.de>
Subject: about the MTRR (memory type range reg)
Message-ID: <Pine.SOL.4.10.9909171005120.2394-100000@elf>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I want to change the memory type of a particular memory region. I know
that the MTRR (Memory Type Range Register) is responsible of that in most
pentium processor-based systems. My question is to know if there is an API
in Linux to access this register (if yes, do you have example ) ?

Thanks,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
