Date: Wed, 20 Sep 2000 01:41:38 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Test8 performance
Message-ID: <20000920014138.A6784@athlon.random>
References: <39C67FA1.89FDCD72@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39C67FA1.89FDCD72@sgi.com>; from ananth@sgi.com on Mon, Sep 18, 2000 at 01:48:33PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

As first thanks again for those very useful benchmark checkpoints.

On Mon, Sep 18, 2000 at 01:48:33PM -0700, Rajagopal Ananthanarayanan wrote:
> ------
> Bonnie
> ------

The "seek" columns of bonnie are calculated with a different input randomized
in function of the pid. I'd suggest to replace the srandom(getpid()) with a
srandom(fixednumber), so that we can more reliably compare the seek column
(it will be comparable as far as the pseudo random generator of glibc uses the
same algorithm).

Also tiotest has the same bug btw.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
