Date: Sat, 12 Oct 2002 18:22:02 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: 2.5.42-mm2
Message-ID: <20021012182202.A27215@nightmaster.csn.tu-chemnitz.de>
References: <3DA7C3A5.98FCC13E@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3DA7C3A5.98FCC13E@digeo.com>; from akpm@digeo.com on Fri, Oct 11, 2002 at 11:39:33PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On Fri, Oct 11, 2002 at 11:39:33PM -0700, Andrew Morton wrote:
> +remove-kiobufs.patch
> 
>  Remove the kiobuf infrastructure.

Stupid question: Would you accept a patch that extends
get_user_pages() to accept an additional "struct scatterlist vector[]"?

Because otherwise we have a senseless pages[] array in memory,
which we copy then into a scatterlist.

A different function using most of get_user_pages() is also
possible.

And last but not least: EXPORT_SYMBOL_GPL() of both, to make it
usable in modules.

Rationale: Most users of get_user_pages() and kiobufs really want
a struct scatterlist sooner or later to transmit it via DMA.

PIO-Users would need a copy_from_user_to_io() and the
counterpart. ALSA implements it somewhere.

So while we are at it... ;-)

Regards

Ingo Oeser
-- 
Science is what we can tell a computer. Art is everything else. --- D.E.Knuth
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
