Date: Mon, 10 Jan 2000 13:52:01 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [PATCH] replace SYSV shared memory with shm filesystem 
In-Reply-To: <qwwvh52ruin.fsf_-_@sap.com>
Message-ID: <Pine.LNX.4.10.10001101350300.584-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: MM mailing list <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.rutgers.edu>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Alexander Viro <viro@math.psu.edu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, GOTO Masanori <gotom@debian.or.jp>
List-ID: <linux-mm.kvack.org>

On 10 Jan 2000, Christoph Rohland wrote:

> You can mount the fs only once. This will probably break shm in
> chrooted environments.

I think it would be best to code it in such a way that you
can mount multiple instances of shmfs, in such a way that
the differently chrooted programs cannot see each other's
shared memory. That should make it a bit more difficult to
get out of a chroot() jail...

(security buffs, please tell me if I'm full of it)

cheers,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
