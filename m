Date: Fri, 19 May 2000 16:55:02 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: PATCH: Enhance queueing/scsi-midlayer to handle kiobufs. [Re: Request splits]
Message-ID: <20000519165502.G9961@redhat.com>
References: <00c201bfc0d7$56664db0$4d0310ac@fairfax.datafocus.com> <200005181955.MAA71492@getafix.engr.sgi.com> <20000519160958.C9961@redhat.com> <20000519084842.A3373@skull.piratehaven.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000519084842.A3373@skull.piratehaven.org>; from bapper@piratehaven.org on Fri, May 19, 2000 at 08:48:42AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>, Chaitanya Tumuluri <chait@getafix.engr.sgi.com>, Eric Youngdale <eric@andante.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Douglas Gilbert <dgilbert@interlog.com>, linux-scsi@vger.rutgers.edu, chait@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, May 19, 2000 at 08:48:42AM -0700, Brian Pomerantz wrote:

> > The real solution is probably not to increase the atomic I/O size, but
> > rather to pipeline I/Os.  That is planned for the future, and now there
> 
> That really depends on the device characteristics.  This Ciprico
> hardware I've been working with really only performs well if the
> atomic I/O size is >= 1MB.  Once you introduce additional transactions
> across the bus, your performance drops significantly.  I guess it is a
> tradeoff between latency and bandwidth.  Unless you mean the low level
> device would be handed a vector of kiobufs and it would build a single
> SCSI request with that vector,

ll_rw_block can already do that, but...

> then I suppose it would work well but
> the requests would have to make up a contiguous chunk of drive space.

... a single request _must_, by definition, be contiguous.  There is
simply no way for the kernel to deal with non-contiguous atomic I/Os.
I'm not sure what you're talking about here --- how can an atomic I/O
be anything else?  We can do scatter-gather, but only from scattered
memory, not to scattered disk blocks.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
