From: Bruno Haible <haible@ilog.fr>
Date: Thu, 2 Dec 1999 21:52:51 +0100 (MET)
Message-Id: <199912022052.VAA24022@jaures.ilog.fr>
Subject: Re: [RFC] mapping parts of shared memory
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I was investigating for some time about the possibility to create some
> object which allows me to map and unmap parts of it it in different
> processes.

5) Use the proc filesystem. Implement a file /proc/ipc/shm/42 as being
   equivalent to the shared memory segment with id 42.
   File type: regular file
   File size: the shm segment's size
   File contents (for use by read, write, mmap): the shm segment's data
   File owner/group: the shm segment's owner and group
   truncate(): return -EINVAL

Not only would this solve your "mmap of shared memory" problem, it would
become possible to view and edit shared memory using "cat", "hexdump" and
"vi". Benefits of the "everything is a file" philosophy.

Bruno
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
