Date: Fri, 24 Mar 2000 15:17:08 +0100
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: /dev/recycle
Message-ID: <20000324151708.A21237@pcep-jamie.cern.ch>
References: <20000322233147.A31795@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003231332080.20600-100000@funky.monkey.org> <20000324010031.B20140@pcep-jamie.cern.ch> <qwwitycivbx.fsf@sap.com> <20000324141001.A21036@pcep-jamie.cern.ch> <qwwd7okiick.fsf@sap.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <qwwd7okiick.fsf@sap.com>; from Christoph Rohland on Fri, Mar 24, 2000 at 02:54:35PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Rohland wrote:
> > Open /dev/recycle several times and map it shared -- it's the same as
> > anonymous shared mappings.  The owner of pages is considered to be the
> > filehandle itself in that case.
> 
> It's not the same as posix shared mem.

What's the difference?

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
