From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14488.15900.402996.763628@dukat.scot.redhat.com>
Date: Wed, 2 Feb 2000 14:24:28 +0000 (GMT)
Subject: Re: [PATCH] shm fs v2 against 2.3.41
In-Reply-To: <20000201190720E.gotom@fe.dis.titech.ac.jp>
References: <qwwemazzj8u.fsf@sap.com>
	<20000201190720E.gotom@fe.dis.titech.ac.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: GOTO Masanori <gotom@debian.or.jp>
Cc: hans-christoph.rohland@sap.com, linux-kernel@vger.rutgers.edu, linux-MM@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 01 Feb 2000 19:07:20 +0900, GOTO Masanori <gotom@debian.or.jp>
said:

> I guess almost all users have no shmpath (default: /var/shm),
> and they maybe make a dir and have to mount it.
> IMHO, it is better to change that sysv shared memory works
> samely, whenever shmfs is not mounted. Is it feasible, 
> or only my mistaken ?

Even tools as fundamental as "ps" don't work until /proc is mounted, so
I don't see anything wrong with requiring shmfs to be mounted for sysV
shared memory to work correctly.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
