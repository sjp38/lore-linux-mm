Date: Thu, 2 Dec 1999 16:18:34 -0500 (EST)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: [RFC] mapping parts of shared memory
In-Reply-To: <199912022052.VAA24022@jaures.ilog.fr>
Message-ID: <Pine.GSO.4.10.9912021615230.19875-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bruno Haible <haible@ilog.fr>
Cc: Christoph Rohland <hans-christoph.rohland@sap.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 2 Dec 1999, Bruno Haible wrote:

> 5) Use the proc filesystem. Implement a file /proc/ipc/shm/42 as being
>    equivalent to the shared memory segment with id 42.
>    File type: regular file
>    File size: the shm segment's size
>    File contents (for use by read, write, mmap): the shm segment's data
>    File owner/group: the shm segment's owner and group
>    truncate(): return -EINVAL
> 
> Not only would this solve your "mmap of shared memory" problem, it would
> become possible to view and edit shared memory using "cat", "hexdump" and
> "vi". Benefits of the "everything is a file" philosophy.

Don't do it in procfs. Make a separate filesystem and mount it on the
empty directory in /proc, if you really need it (I'ld rather use some
other location - even /dev/shm would be better). This filesystem will have
_nothing_ with proc in terms of code. There is enough mess in procfs
already. Keep this one separate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
