Subject: Re: 2.5.34-mm4
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <Pine.LNX.4.44L.0209151554520.1857-100000@imladris.surriel.com>
References: <Pine.LNX.4.44L.0209151554520.1857-100000@imladris.surriel.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 16 Sep 2002 02:33:36 +0100
Message-Id: <1032140016.26857.24.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrew Morton <akpm@digeo.com>, "M. Edward Borasky" <znmeb@aracnet.com>, Axel Siebenwirth <axel@hh59.org>, Con Kolivas <conman@kolivas.net>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, lse-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Sun, 2002-09-15 at 19:56, Rik van Riel wrote:
> On Sun, 15 Sep 2002, Andrew Morton wrote:
> 
> > - In -ac, there are noticeable stalls during heavy writeout.  This
> >   may be an ext3 thing, but I can't think of any IO scheduling
> >   differences in -ac ext3.  I'd be guessing that it is due to
> >   bdflush/kupdate lumpiness.

I think so. I've always been conservative, I need rmap to pass cerberus
still. But the rmap in -ac is out of date a little with the 2.5 tuning

> This is also due to the fact that -ac has an older -rmap
> VM. As in current 2.5, rmap can write out all inactive
> pages ... and it did in some worst case situations.
> 
> This is fixed in rmap14.
> 
> (I hope Alan is done playing with IDE soon so I can push
> him a VM update)

The big one left to fix is the simplex device bug - which is an "I know
why". The great mystery is the affair of taskfile pio write. Other than
that its annoying glitches not big problems now.

So send me rmap-14a patches by all means

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
