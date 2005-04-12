Subject: Re: mapping large amount of memory on physical addresses
Message-ID: <OF967F18DF.AC2C3352-ONC1256FE1.0022ECD3@brime.fr>
From: scarayol@assystembrime.com
Date: Tue, 12 Apr 2005 08:23:46 +0200
MIME-Version: 1.0
Content-type: text/plain; charset=iso-8859-1
Content-transfer-encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

 I wrote 2 drivers very close to the driver /dev/mem in order to write in
 the physical memory at specific addresses. For that I use mmap
instruction.
 I want to know, if there is a limit  for the maximum amount of physical
 memory that I can map with a single the mmap instruction.

 My platform is a MPC885 (PowerPC) on a MPC885ADS board and I have a 2.4.26
 kernel.

 Now I map 2 zones of 1MB (first zone at 6MB and the 2nd at 7MB:I have 8MB
 on my board), each on the same physical component (to have data
 transfertsbetween the two zones). But, in  the final application (on our
 own card) one zone will represent 2MB for a component of 2MB and  and the
 other 216 MB for another component of 256MB. So, it will let 40MB for the
 kernel, FileSystem, etc.
 How can I be sure that linux let me reserve all these physical addresses ?
 If I use the command 'mem=6M' in u-boot to force Linux in the first 6M,
the
 mem driver accesses don't work any more.

 If mmap doesn't work for such an amount of memory (216 MB) how can I do ?

 Last question: How could I verify the mapping by a shell command or a
 memory dump... ?

 Thank you really for your help.

----------------------------------------------------------
Sophie CARAYOL

TECHNOLOGIES & SYSTEMES
50 rue du President Sadate
F - 29337 QUIMPER CEDEX

Tel: +33 2 98 10 30 06
mailto:scarayol@assystembrime.com
----------------------------------------------------------


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
