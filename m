Subject: Re: /dev/recycle
References: <20000322233147.A31795@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003231332080.20600-100000@funky.monkey.org> <20000324010031.B20140@pcep-jamie.cern.ch> <qwwitycivbx.fsf@sap.com> <20000324141001.A21036@pcep-jamie.cern.ch> <qwwd7okiick.fsf@sap.com> <20000324151708.A21237@pcep-jamie.cern.ch> <qwwpuskgtaz.fsf@sap.com> <20000324191313.E21539@pcep-jamie.cern.ch>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 25 Mar 2000 09:35:01 +0100
In-Reply-To: Jamie Lokier's message of "Fri, 24 Mar 2000 19:13:13 +0100"
Message-ID: <qwwg0tfh2h6.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Christoph Rohland <hans-christoph.rohland@sap.com>, Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jamie Lokier <lk@tantalophile.demon.co.uk> writes:

> Christoph Rohland wrote:
> > 1) /dev/{zero,recycle} shared mappings do only work between childs of
> >    the same parent and the parent. Also they do not survive an exec.
> 
> Use file handle passing -- another process can then share the mapping.
> This is what shared anonymous mapping means, and it was added to the
> kernel recently just after posix shm (because posix shm made it easy to
> implement).

That's not how /dev/zero works. Check the implementation. AFAIK it
also does not work this way on other platforms.
 
> > 2) You cannot unmap and remap the same area.
> 
> You can if someone else holds it open.

See above.

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
