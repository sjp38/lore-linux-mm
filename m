Subject: Re: /dev/recycle
References: <20000322233147.A31795@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003231332080.20600-100000@funky.monkey.org> <20000324010031.B20140@pcep-jamie.cern.ch> <qwwitycivbx.fsf@sap.com> <20000324141001.A21036@pcep-jamie.cern.ch> <qwwd7okiick.fsf@sap.com> <20000324151708.A21237@pcep-jamie.cern.ch>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 24 Mar 2000 18:40:52 +0100
Message-ID: <qwwpuskgtaz.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Christoph Rohland <hans-christoph.rohland@sap.com>, Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jamie Lokier <lk@tantalophile.demon.co.uk> writes:

> Christoph Rohland wrote:
> > > Open /dev/recycle several times and map it shared -- it's the same as
> > > anonymous shared mappings.  The owner of pages is considered to be the
> > > filehandle itself in that case.
> > 
> > It's not the same as posix shared mem.
> 
> What's the difference?

1) /dev/{zero,recycle} shared mappings do only work between childs of
   the same parent and the parent. Also they do not survive an exec.
2) You cannot unmap and remap the same area.

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
