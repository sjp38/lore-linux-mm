Message-ID: <3DA1A95C.AE5076D5@scs.ch>
Date: Mon, 07 Oct 2002 17:33:48 +0200
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: question on mmput()
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Hello,

I write a device driver, that accesses a processes user space memory. In case of an unexpected exit of the user space process (i.e. an exit while the underlying hardware
device is set up to transfer data in to the processes memory), the driver while still need access to the processes (former)  memory (e.g. to unlock the pages the driver did
lock, when the transfer was set up).

When the drivers open() file operation is called, it increments the mm_users field in the processes mm_struct, to prevent it from being released, while the driver still
needs to access it.
Once the driver is done with the mm_struct, it should call mmput(), to decrement the usage count, and release the mm_struct if the count drops to 0. Unfortunatly mmput() is
not exported by the kernel (vers. 2.4.18), and can therefore not be used by the driver, which is compiled as a module.

1) Why is mmput() not exported as a symbol?

2) Is there any alternate solution, to properly release the mm_struct once the driver is done with it?

Thanks in advance for any help
with best regards
Martin Maletinsky

P.S. Please put me on CC: in your reply, since I am not in the mailing list.

--
Supercomputing System AG          email: maletinsky@scs.ch
Martin Maletinsky                 phone: +41 (0)1 445 16 05
Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
CH-8005 Zurich


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
