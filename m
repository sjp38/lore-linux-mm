Date: Fri, 10 Nov 2000 09:56:43 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Question about swap_in() in 2.2.16 ....
Message-ID: <20001110095643.A15453@redhat.com>
References: <3A08F37A.38C156C1@cse.iitkgp.ernet.in> <20001108100533.C11411@redhat.com> <3A0B7829.B9F33ACA@cse.iitkgp.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3A0B7829.B9F33ACA@cse.iitkgp.ernet.in>; from sganguly@cse.iitkgp.ernet.in on Thu, Nov 09, 2000 at 11:23:05PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shuvabrata Ganguly <sganguly@cse.iitkgp.ernet.in>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Nov 09, 2000 at 11:23:05PM -0500, Shuvabrata Ganguly wrote:
> "Stephen C. Tweedie" wrote:
> > > Now this creates a read-only mapping  even if the access was a "write
> > > acess"  ( if the page is shared ). Doesnt this mean that an additional
> > > "write-protect" fault will be taken immediately when the process tries
> > > to write again ?
> >
> > Yes.
> 
> Then why dont we give it a private page in the first place ?

Normal copy-on-write is an extremely performance-critical code path.
It's really not worth the trouble of adding extra code to it to make
the swapin page fault do the same copy-on-write immediately, because
swapin simply is not that important for performance.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
