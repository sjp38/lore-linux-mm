Date: Wed, 5 Sep 2001 21:45:52 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] /proc/meminfo (fwd)
Message-ID: <20010905214552.B32584@athlon.random>
References: <Pine.LNX.4.33.0109051538400.16684-100000@toomuch.toronto.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0109051538400.16684-100000@toomuch.toronto.redhat.com>; from bcrl@redhat.com on Wed, Sep 05, 2001 at 03:38:57PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Arjan van de Ven <arjanv@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 05, 2001 at 03:38:57PM -0400, Ben LaHaise wrote:
> Heyo,
> 
> Below is a patch to fix overflows in /proc/meminfo on machines with lots
> of highmem.  I wish I had 64GB.  Dell was right -- I was reading the
> MemTotal: line automatically instead of Mem:.

I fixed such bug ages ago:

	ftp://ftp.us.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.4/2.4.10pre4aa1/00_meminfo-wraparound-2

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
