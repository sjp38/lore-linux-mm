Subject: Re: [PATCH] replace SYSV shared memory with shm filesystem
References: <qwwvh52ruin.fsf_-_@sap.com> <20000110145913.01335@colin.muc.de>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 10 Jan 2000 18:55:45 +0100
Message-ID: <qwwya9xreu6.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: MM mailing list <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.rutgers.edu>, Rik van Riel <riel@nl.linux.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen <ak@muc.de> writes:

> On Mon, Jan 10, 2000 at 01:20:40PM +0100, Christoph Rohland wrote:
> > Hi folks,
> > 
> > This patch implements a minimal filesystem for shared memory. It
> > replaces/reuses the existing SYSV shm code so you now have to mount
> > the fs to be able to use SYSV SHM. But in turn we now have everything
> > in place to implement posix shm. This also obsoletes vm_private_data
> > in vm_area_struct.
> 
> I planed to map the Unix Sockets abstract name space to a file system
> for some time now.  Because it would be silly to write another file
> system just for that rather obscure feature, would it be possible
> to use a subdirectory in your new shm filesystem? I haven't looked
> at the code at all yet, and don't know if it can even deal with 
> directories and special devices. Do you have objections to such 
> a direction?

In the current state this is not possible. The shm fs does not support
directories and only regular files (which you can only mmap, no
read/write support).

But we could later extend the fs to support directories and special
files. The Unix Sockets could probably also use the same mechanisms
for locating the special fs like SYSV ipc does.

With these changes we also should then be able to mount the fs several
times. So we also get the chroot case fixed.

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
