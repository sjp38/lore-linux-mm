Date: Mon, 27 Mar 2000 17:17:39 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: compressed swap
Message-ID: <20000327171739.F10820@redhat.com>
References: <38DF5901.CEBF90B0@nibiru.pauls.erfurt.thur.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <38DF5901.CEBF90B0@nibiru.pauls.erfurt.thur.de>; from weigelt@nibiru.pauls.erfurt.thur.de on Mon, Mar 27, 2000 at 12:50:09PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Enrico Weigelt <weigelt@nibiru.pauls.erfurt.thur.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Mar 27, 2000 at 12:50:09PM +0000, Enrico Weigelt wrote:
> 
> i'm currenty thinking about a compressed swapspace-manager.
> not to save diskspace, but to reduce the IO-upcome.
> 
> in today's PCs the blottleneck is the disk-bandwith when the
> system is swapping.i

Not really.  You are far more limited by the seek performance of the
disk than by its bandwidth.  If you wanted to optimise it, you would
be far, far better off trying to make swap stream on and off the disk
in larger units rather than compressing it.  (The clustering code in
the 2.2 VM does this for swapin, and the kswapd is tuned to do it for
swapout, to some extent already.)

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
