Received: from sphinx.cs.tu-berlin.de (pokam@sphinx.cs.tu-berlin.de [130.149.31.22])
	by mail.cs.tu-berlin.de (8.9.1/8.9.1) with ESMTP id QAA14157
	for <linux-mm@kvack.org>; Thu, 12 Aug 1999 16:19:28 +0200 (MET DST)
From: Gilles Pokam <pokam@cs.tu-berlin.de>
Received: (from pokam@localhost)
	by sphinx.cs.tu-berlin.de (8.9.1/8.9.0) id QAA16816
	for linux-mm@kvack.org; Thu, 12 Aug 1999 16:19:26 +0200 (MET DST)
Message-Id: <199908121419.QAA16816@sphinx.cs.tu-berlin.de>
Subject: vremap question
Date: Thu, 12 Aug 1999 16:19:25 +0200 (MET DST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Are there some restrictions on the use of vremap ?

I am trying to map 1MB of my PCI-device memory into kernel space. Having the base
i/o address and the span of my device memory i use the ioremap function like this:
 virt = ioremap_nocache(base_io,size);

my device memory is subdivided like this: 216kb of unused memory,216kb of prom,128kb 
register,128kb fpga and 216kb of sram. After the ioremap call, i can access the prom
region, but any attempt to read or write the sram,register or fpga region yields 0x0!

can someone tell me what is wrong ?

Thanks.

 
-- 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
