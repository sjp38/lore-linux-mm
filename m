Date: Sun, 28 May 2000 23:42:13 +0100
From: Stephen Tweedie <sct@redhat.com>
Subject: Re: [RFC] 2.3/4 VM queues idea
Message-ID: <20000528234213.B3356@redhat.com>
References: <20000526120805.C10082@redhat.com> <20000526132219.C21510@pcep-jamie.cern.ch> <20000526141526.E10082@redhat.com> <20000526163129.B21662@pcep-jamie.cern.ch> <20000526153821.N10082@redhat.com> <20000526183640.A21731@pcep-jamie.cern.ch> <20000526174018.Q10082@redhat.com> <20000526190208.A21856@pcep-jamie.cern.ch> <20000526181509.R10082@redhat.com> <20000526224113.A22069@pcep-jamie.cern.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000526224113.A22069@pcep-jamie.cern.ch>; from lk@tantalophile.demon.co.uk on Fri, May 26, 2000 at 10:41:13PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Matthew Dillon <dillon@apollo.backplane.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, May 26, 2000 at 10:41:13PM +0200, Jamie Lokier wrote:
> Stephen C. Tweedie wrote:
> > > The stacked private address_spaces I described don't have to be shared
> > > between address_spaces in a single mm.  You can have one per vma --
> > > that's simple but maybe wasteful.
> > 
> > That's basically exactly what davem's stuff did.
> 
> Ok, I shall look more carefully at davem's code.
> Is this the most recent one?:

Yes, I think he dropped it at this point.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
