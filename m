Date: Fri, 19 May 2000 08:48:42 -0700
From: Brian Pomerantz <bapper@piratehaven.org>
Subject: Re: PATCH: Enhance queueing/scsi-midlayer to handle kiobufs. [Re: Request splits]
Message-ID: <20000519084842.A3373@skull.piratehaven.org>
References: <00c201bfc0d7$56664db0$4d0310ac@fairfax.datafocus.com> <200005181955.MAA71492@getafix.engr.sgi.com> <20000519160958.C9961@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000519160958.C9961@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Chaitanya Tumuluri <chait@getafix.engr.sgi.com>, Eric Youngdale <eric@andante.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Douglas Gilbert <dgilbert@interlog.com>, linux-scsi@vger.rutgers.edu, chait@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 19, 2000 at 04:09:58PM +0100, Stephen C. Tweedie wrote:
> Hi,
> 
> On Thu, May 18, 2000 at 12:55:04PM -0700, Chaitanya Tumuluri wrote:
>  
> > I've had the same question in my mind. I've also wondered why raw I/O was
> > restricted to only KIO_MAX_SECTORS at a time.
> 
> Mainly for resource limiting --- you don't want to have too much user
> memory pinned permanently at once.
> 
> The real solution is probably not to increase the atomic I/O size, but
> rather to pipeline I/Os.  That is planned for the future, and now there

That really depends on the device characteristics.  This Ciprico
hardware I've been working with really only performs well if the
atomic I/O size is >= 1MB.  Once you introduce additional transactions
across the bus, your performance drops significantly.  I guess it is a
tradeoff between latency and bandwidth.  Unless you mean the low level
device would be handed a vector of kiobufs and it would build a single
SCSI request with that vector, then I suppose it would work well but
the requests would have to make up a contiguous chunk of drive space.


BAPper
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
