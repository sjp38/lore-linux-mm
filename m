Subject: Re: [PATCH] get rid of vm_private_data and win posix shm
References: <E1230lm-0000h1-00@the-village.bc.nu>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 28 Dec 1999 19:38:28 +0100
In-Reply-To: Alan Cox's message of "Tue, 28 Dec 1999 17:50:48 +0000 (GMT)"
Message-ID: <qwwyaaegbbv.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, ebiederm+eric@ccr.net, Alexander Viro <viro@math.psu.edu>
List-ID: <linux-mm.kvack.org>

Alan Cox <alan@lxorguk.ukuu.org.uk> writes:

> > I implemented posix shm with its own namespace by extending filp_open
> > and do_unlink by an additional parameter for the root inode.
> > Also extending this to a complete filesystem should be easy (but not
> > my target).
> 
> It would seem that the best way to fix the inelegance of the patch - the
> shm_open and shm_unlink syscalls, the hacks on filp_open etc would be to do
> exactly that - make it a real fs, at least for open/unlink/openddir/readdir
> even if not for read/write

This makes the sysv ipc code dependent on a mounted fs. Also the
library has to know where this shm fs is mounted to implement shm_open
etc. I do not like these ideas. But I know this is questionable.

I will redo my patch to be much less intrusive into other code.

Greetings
		Christoph

-- 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
