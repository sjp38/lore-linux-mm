Date: Sun, 15 Sep 2002 15:56:14 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.5.34-mm4
In-Reply-To: <3D84D799.557653C7@digeo.com>
Message-ID: <Pine.LNX.4.44L.0209151554520.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "M. Edward Borasky" <znmeb@aracnet.com>, Axel Siebenwirth <axel@hh59.org>, Con Kolivas <conman@kolivas.net>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, lse-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Sun, 15 Sep 2002, Andrew Morton wrote:

> - In -ac, there are noticeable stalls during heavy writeout.  This
>   may be an ext3 thing, but I can't think of any IO scheduling
>   differences in -ac ext3.  I'd be guessing that it is due to
>   bdflush/kupdate lumpiness.

This is also due to the fact that -ac has an older -rmap
VM. As in current 2.5, rmap can write out all inactive
pages ... and it did in some worst case situations.

This is fixed in rmap14.

(I hope Alan is done playing with IDE soon so I can push
him a VM update)

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
