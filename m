Subject: Re: [PATCH] replace SYSV shared memory with shm filesystem
References: <E127e6y-0003A8-00@the-village.bc.nu>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 10 Jan 2000 13:46:22 +0100
In-Reply-To: Alan Cox's message of "Mon, 10 Jan 2000 12:39:50 +0000 (GMT)"
Message-ID: <qwwpuvart5t.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: MM mailing list <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.rutgers.edu>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Alexander Viro <viro@math.psu.edu>, GOTO Masanori <gotom@debian.or.jp>
List-ID: <linux-mm.kvack.org>

Alan Cox <alan@lxorguk.ukuu.org.uk> writes:

> > replaces/reuses the existing SYSV shm code so you now have to
> > mount the fs to be able to use SYSV SHM. But in turn we now have
> > everything in place to implement posix shm. This also obsoletes
> > vm_private_data in vm_area_struct.
> 
> Umm no. It obsoletes vm_private_data for existing merged file
> systems. The stackable file systems still need this field (cryptfs,
> lofs etc)

Hey, that's a pity :-( I liked this cleanup. Do they really need it?

> > Also it is now possible to do e.g. 'rm /dev/shm/*' instead of this
> >terrible 'ipcrm shm xx' :-)
> 
> Nice

Yup :-)

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
