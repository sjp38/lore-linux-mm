Message-ID: <3B6A5A52.73D0DC12@scs.ch>
Date: Fri, 03 Aug 2001 10:01:22 +0200
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: Changes in vm_operations_struct 2.2.x => 2.4.x
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Playing around with kernel memory allocated by a module and mmap()ed by a user space process, I noticed that in the 2.4.x kernel many of the 2.2.x vm_operation_struct
fields have gone. In particular there is no unmap operation any more. Is there any way for a driver to get notified when the user space process mapping memory exported by
the driver unmaps parts of that memory (as far as I know, the close operation is invoked when the entire memory is unmapped)? Does anyone know the reason why the number of
operations in vm_operation_struct has been reduced?

regards
Martin

--
Supercomputing System AG          email: maletinsky@scs.ch
Martin Maletinsky                 phone: +41 (0)1 445 16 05
Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
CH-8005 Zurich


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
