Subject: Re: [PATCH] replace SYSV shared memory with shm filesystem
Date: Mon, 10 Jan 2000 12:39:50 +0000 (GMT)
In-Reply-To: <qwwvh52ruin.fsf_-_@sap.com> from "Christoph Rohland" at Jan 10, 2000 01:17:04 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E127e6y-0003A8-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: MM mailing list <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.rutgers.edu>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Alexander Viro <viro@math.psu.edu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, GOTO Masanori <gotom@debian.or.jp>
List-ID: <linux-mm.kvack.org>

> replaces/reuses the existing SYSV shm code so you now have to mount
> the fs to be able to use SYSV SHM. But in turn we now have everything
> in place to implement posix shm. This also obsoletes vm_private_data
> in vm_area_struct.

Umm no. It obsoletes vm_private_data for existing merged file systems. The stackable
file systems still need this field (cryptfs, lofs etc)

> Also it is now possible to do e.g. 'rm /dev/shm/*' instead of this
> terrible 'ipcrm shm xx' :-)

Nice

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
