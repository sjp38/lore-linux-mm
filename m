Received: from [194.5.49.5] (macsteph.grame.fr [194.5.49.5])
	by rd.grame.fr (8.9.3/8.9.3) with ESMTP id SAA30458
	for <linux-mm@kvack.org>; Tue, 23 May 2000 18:07:13 +0200
Message-Id: <v03007809b5505bfec2a5@[194.5.49.5]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 23 May 2000 18:16:58 +0200
From: Stephane Letz <letz@grame.fr>
Subject: Accessing shared memory in a kernel module
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We are developing an application where we need to access shared memory both
in user space and in a kernel module.  We use a shared memory segment to
preallocate memory cells which are later communicated between several
applications in user space.  These memory cells are time stamped and use a
reference counter. To exchange cells between applications in user space,
they are first inserted in a scheduler  (located in a kernel module) to be
delivered to the destination application at the right time.
The kernel module need to access the reference counter field of each cell.

We tried to use standard shmxx functions to manage shared memory and it
work OK in user space, but we can not access the cell content in the kernel
context.

How can that be done?

Thanks in advance for any advice

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
