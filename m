Received: from flying.demon.nl (flying.demon.nl [195.173.241.9])
	by kvack.org (8.8.7/8.8.7) with SMTP id NAA21242
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 13:22:13 -0500
Date: Sun, 10 Jan 1999 18:13:38 +0100 (CET)
From: Jelle Foks <jelle@flying.demon.nl>
Subject: I/O and MM question
Message-ID: <Pine.LNX.4.03.9901101752050.13236-100000@zap.zap>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I have a question about memory management in Linux and low-overhead I/O
between devices and the file system.

I have a device that has memory-mapped access. In a system with 8MB of RAM
(where the kernel reports and uses only 8MB of RAM), the device responds
to memory read and write accesses in the region 8-16MB. What I need to do
is fast I/O between the device the hard drive. Currently, I access the
device from a module that has mapped the device's I/O RAM addresses to a
pointer with vremap(). This way, I should be able to make a character
device that allows a user space process to fread() from the device and
fwrite() to the hard drive (and vice versa). However, I'd like to
eliminate the memory copy to/from the user-space process's buffer, and do
something like an fwrite() directly from the simulated-RAM provided by the
device (or probably better a memcpy() from the device to a mmap()ped file
from disk).

Can I give a user process read/write access to the RAM from the device?
(how/which function to use?). Does the mm/paging system of Linux allow me
this? Or does the mm/paging code already somehow eliminate the memory-copy
of the fread()->fwrite() combo (how?)? Or should/could I use a scheme
where the user space process gives the pointer of a mmap()ed file to the
device driver, and let the device driver itself do a memcpy() to the
mmap()ped file?

Does anybody have any hints, ideas, etc?

Greetings,
Jelle.


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
