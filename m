Date: Wed, 5 Sep 2001 22:08:58 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] /proc/meminfo (fwd)
Message-ID: <20010905220858.A11329@athlon.random>
References: <20010905214552.B32584@athlon.random> <Pine.LNX.4.33.0109051559270.16684-100000@toomuch.toronto.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0109051559270.16684-100000@toomuch.toronto.redhat.com>; from bcrl@redhat.com on Wed, Sep 05, 2001 at 04:00:28PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Arjan van de Ven <arjanv@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 05, 2001 at 04:00:28PM -0400, Ben LaHaise wrote:
> On Wed, 5 Sep 2001, Andrea Arcangeli wrote:
> 
> > I fixed such bug ages ago:
> >
> > 	ftp://ftp.us.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.4/2.4.10pre4aa1/00_meminfo-wraparound-2
> 
> Is it scheduled for merging?  Arjan mentioned that it may have broken some

I don't remeber if I've sent it to Linus or not yet but yes.

> apps (like top) and have been pulled earlier.  My vote is for letting them

never got a bugreport about it so I guess top should be ok but if top
breaks it is the one that has to be fixed so...

> break and get fixed on highmem machines, but other people might have
> different opinions.

I certainly agree with you.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
