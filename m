MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14620.2180.8684.529000@charged.uio.no>
Date: Fri, 12 May 2000 15:35:00 +0200 (CEST)
Subject: Re: PATCH: rewrite of invalidate_inode_pages
In-Reply-To: <m12qFNa-000OVtC@amadeus.home.nl>
References: <Pine.LNX.4.10.10005111445370.819-100000@penguin.transmeta.com>
	<yttya5ghhtr.fsf@vexeta.dc.fi.udc.es>
	<shsd7msemwu.fsf@charged.uio.no>
	<yttbt2chf46.fsf@vexeta.dc.fi.udc.es>
	<14619.16278.813629.967654@charged.uio.no>
	<ytt1z38acqg.fsf@vexeta.dc.fi.udc.es>
	<391BEAED.C9313263@sympatico.ca>
	<yttg0ro6lt8.fsf@vexeta.dc.fi.udc.es>
	<shs7ld0dj8x.fsf@charged.uio.no>
	<m12qFNa-000OVtC@amadeus.home.nl>
Reply-To: trond.myklebust@fys.uio.no
From: Trond Myklebust <trond.myklebust@fys.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@fenrus.demon.nl>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> " " == Arjan van de Ven <arjan@fenrus.demon.nl> writes:


    >> Could you please look into changing the name of
    >> invalidate_inode_pages() to invalidate_pages_noblock() or
    >> something like that? Since NFS is the only place where this
    >> function is used, a change of name should not break any other
    >> code.

     > I'd vote for "invalidate_unlocked_inode_pages", as it also
     > suggests that the locked pages aren't invalidated.

That sounds very good to me. Just so long as the name becomes more
self-documenting than it is now.
Intelligent people are making mistakes about what we want to do with
this function, so it definitely needs to be documented more clearly.

Cheers,
  Trond
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
