Received: from [194.5.49.5] (macsteph.grame.fr [194.5.49.5])
	by rd.grame.fr (8.9.3/8.9.3) with ESMTP id NAA01469
	for <linux-mm@kvack.org>; Wed, 24 May 2000 13:05:28 +0200
Message-Id: <v03007801b55167f9bf16@[194.5.49.5]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 24 May 2000 13:14:40 +0200
From: Stephane Letz <letz@grame.fr>
Subject: Large shared memory segment in kernel
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We would like to allocate a large memory segment (several Mb) in a kernel
module so that to access the memory in the kernel module and in user space
application. (be implementing the mmap function in the kernel module)
Is is something that could be done ?  Or kernel modules should only mmap
small amount of memory?

Thanks

Stephane Letz


Grame: Centre National de creation musicale
9, Rue du Garet
69001 Lyon
Tel: 04-72-07-37-00
Fax: 04-72-07-37-01
Web: www.grame.fr


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
