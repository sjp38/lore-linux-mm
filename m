Received: by fenrus.demon.nl
	via sendmail from stdin
	id <m12qFNa-000OVtC@amadeus.home.nl> (Debian Smail3.2.0.102)
	for linux-mm@kvack.org; Fri, 12 May 2000 15:21:22 +0200 (CEST)
Message-Id: <m12qFNa-000OVtC@amadeus.home.nl>
Date: Fri, 12 May 2000 15:21:22 +0200 (CEST)
From: arjan@fenrus.demon.nl (Arjan van de Ven)
Subject: Re: PATCH: rewrite of invalidate_inode_pages
In-Reply-To: <Pine.LNX.4.10.10005111445370.819-100000@penguin.transmeta.com> <yttya5ghhtr.fsf@vexeta.dc.fi.udc.es> <shsd7msemwu.fsf@charged.uio.no> <yttbt2chf46.fsf@vexeta.dc.fi.udc.es> <14619.16278.813629.967654@charged.uio.no> <ytt1z38acqg.fsf@vexeta.dc.fi.udc.es> <391BEAED.C9313263@sympatico.ca> <yttg0ro6lt8.fsf@vexeta.dc.fi.udc.es> <shs7ld0dj8x.fsf@charged.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In article <shs7ld0dj8x.fsf@charged.uio.no> you wrote:
>>>>>> " " == Juan J Quintela <quintela@fi.udc.es> writes:

>      > This was a first approach patch, if people like the thing
>      > configurable, I can try to do that the weekend.

> Juan, Linus,

>    Could you please look into changing the name of
> invalidate_inode_pages() to invalidate_pages_noblock() or something
> like that? Since NFS is the only place where this function is used, a
> change of name should not break any other code.

I'd vote for "invalidate_unlocked_inode_pages", as it also suggests
that the locked pages aren't invalidated.

Greetings,
   Arjan van de Ven
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
