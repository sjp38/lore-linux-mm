Subject: Re: [PATCH] get rid of vm_private_data and win posix shm
Date: Tue, 28 Dec 1999 17:50:48 +0000 (GMT)
In-Reply-To: <qwwd7rrgeen.fsf@sap.com> from "Christoph Rohland" at Dec 28, 99 06:32:00 pm
Content-Type: text
Message-Id: <E1230lm-0000h1-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, ebiederm+eric@ccr.net
List-ID: <linux-mm.kvack.org>

> I implemented posix shm with its own namespace by extending filp_open
> and do_unlink by an additional parameter for the root inode.
> Also extending this to a complete filesystem should be easy (but not
> my target).

It would seem that the best way to fix the inelegance of the patch - the
shm_open and shm_unlink syscalls, the hacks on filp_open etc would be to do
exactly that - make it a real fs, at least for open/unlink/openddir/readdir
even if not for read/write


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
