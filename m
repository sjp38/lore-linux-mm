Date: Fri, 9 Jun 2000 13:53:51 +0200
From: Ralf Baechle <ralf@uni-koblenz.de>
Subject: Re: journaling & VM
Message-ID: <20000609135351.A20386@uni-koblenz.de>
References: <Pine.LNX.4.21.0006061956360.7328-100000@duckman.distro.conectiva> <393DA31A.358AE46D@reiser.to> <20000607121243.F29432@redhat.com> <m2r9a9a1q6.fsf_-_@boreas.southchinaseas> <20000607181144.U30951@redhat.com> <20000608114435.A15433@uni-koblenz.de> <20000608222950.Z3886@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000608222950.Z3886@redhat.com>; from sct@redhat.com on Thu, Jun 08, 2000 at 10:29:50PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 08, 2000 at 10:29:50PM +0100, Stephen C. Tweedie wrote:

> On Thu, Jun 08, 2000 at 11:44:35AM +0200, Ralf Baechle wrote:

> > some device drivers may also collect relativly large amounts of memory.
> > In case of my HIPPI cards this may be in the range of megabytes.  So I'd
> > like to see a hook for freeing device memory.

> Device drivers really are a special case because they typically need
> their memory at short notice, and at awkward times (such as in the 
> middle of interrupts).  What sort of flexibility do you have regarding
> the allocation/release of the buffer pull in your driver?

I can release those buffers immediately.  The driver only holds them for
some while since it delays cleaning the tx ring, depending on the various
interrupt avoidance strategies we might use even indefinately.  Allocation
on rx is done at interrupt time but that's no big deal, if we fail to
allocate memory we just drop the packet and try again later.  Such
interrupt avoidance is actually a very common thing for alot of NICs.  The
(rare...) HIPPI case is worst because HIPPI has the largest MTU with 64kb.

  Ralf
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
