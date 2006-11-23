Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kAN8p3uO026860
	for <linux-mm@kvack.org>; Thu, 23 Nov 2006 08:51:03 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAN8rt812527258
	for <linux-mm@kvack.org>; Thu, 23 Nov 2006 08:53:55 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAN8p3in010277
	for <linux-mm@kvack.org>; Thu, 23 Nov 2006 08:51:03 GMT
Received: from localhost (dyn-9-152-216-55.boeblingen.de.ibm.com [9.152.216.55])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id kAN8p3ke010253
	for <linux-mm@kvack.org>; Thu, 23 Nov 2006 08:51:03 GMT
Date: Thu, 23 Nov 2006 09:49:40 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: VMALLOC_END definition?
Message-ID: <20061123084940.GA8009@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I just stumbled across the VMALLOC_END definition: I'm not entirely sure
what the meaning of this is: is it the last _valid_ address of the
vmalloc area or is it the first address _after_ the vmalloc area?

Reading the code in mm/vmalloc.c it seems to be the last valid address,
which IMHO is the only thing that makes sense... how would one express
the first address after 0xffffffff on a 32bit architecture?
Whatever it is, it looks like half of the architectures got it wrong.

We have a lot of these:

e.g. powerpc:
#define VMALLOC_START ASM_CONST(0xD000000000000000)
#define VMALLOC_SIZE  ASM_CONST(0x80000000000)
#define VMALLOC_END   (VMALLOC_START + VMALLOC_SIZE)

but also a lot of these:

e.g. x86_64

#define VMALLOC_START    0xffffc20000000000UL
#define VMALLOC_END      0xffffe1ffffffffffUL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
